defmodule SmartEnergy.User.Worker do
  @moduledoc false

  use GenServer

  import Application

  alias SmartEnergy.Devices.DeviceProducer
  alias SmartEnergy.PubSub
  alias SmartEnergy.Registry
  alias SmartEnergy.Devices.Models.{ConsumptionUpdate, StatusChange}

  @module_name __MODULE__

  def start_link(args) do
    with key when not is_nil(key) <- Keyword.get(args, :key),
         name <- Registry.via(key) do
      GenServer.start_link(@module_name, args, name: name)
    else
      _ -> {:error, :invalid_args}
    end
  end

  def pair_new_device(worker_pid, device_id),
    do: GenServer.cast(worker_pid, {:pair_new_device, device_id})

  def get_paired_devices(worker_pid),
    do: GenServer.call(worker_pid, :get_paired_devices)

  def get_device_data(worker_pid, device_id),
    do: GenServer.call(worker_pid, {:get_device_data, device_id})

  def change_device_status(worker_pid, device_id, status),
    do: GenServer.call(worker_pid, {:change_device_status, device_id, status})

  def init(args) do
    user_id = Keyword.get(args, :user_id)
    session_guid = Keyword.get(args, :session_guid)
    {:ok, %{user_id: user_id, session_guid: session_guid, paired_devices: %{}}}
  end

  def handle_cast({:pair_new_device, device_id}, state) do
    PubSub.subscribe_device_updates(device_id)
    %{paired_devices: paired_devices} = state

    paired_devices =
      if Map.get(paired_devices, device_id) === nil do
        # TODO: pairing handshake? RPC /
        # to know the current state of the device and the adress/queue that I communicate with it
        Map.put(paired_devices, device_id, %{
          consumption: nil,
          status: nil,
          reply_to: get_devices_reply_to()
        })
      else
        paired_devices
      end

    {:noreply, %{state | paired_devices: paired_devices}}
  end

  def handle_call({:change_device_status, device_id, status}, _, state) do
    %{paired_devices: paired_devices} = state

    # TODO: constants loader for device statuses
    status =
      if is_binary(status) do
        String.to_integer(status)
      else
        status
      end

    paired_devices =
      case Map.get(paired_devices, device_id) do
        nil ->
          paired_devices

        paired_device_data ->
          if DeviceProducer.publish(
               %{message: "UpdateStatus", payload: %{status: status}},
               paired_device_data.reply_to
             ) === {:ok, false} do
            Map.put(paired_devices, device_id, %{paired_device_data | status: status})
          else
            paired_devices
          end
      end

    state = %{state | paired_devices: paired_devices}
    {:reply, Map.get(paired_devices, device_id), %{state | paired_devices: paired_devices}}
  end

  def handle_call(:get_paired_devices, _, %{paired_devices: paired_devices} = state) do
    {:reply, paired_devices, state}
  end

  def handle_call({:get_device_data, device_id}, _, %{paired_devices: paired_devices} = state) do
    device_data =
      case Map.get(paired_devices, device_id) do
        nil -> nil
        device_data -> Map.delete(device_data, :reply_to)
      end

    {:reply, device_data, state}
  end

  def handle_info(
        {:device_update, %ConsumptionUpdate{device_id: device_id, consumption: consumption}},
        state
      ) do
    %{paired_devices: paired_devices} = state

    paired_devices =
      case Map.get(paired_devices, device_id) do
        nil ->
          paired_devices

        paired_device_data ->
          Map.put(paired_devices, device_id, %{paired_device_data | consumption: consumption})
      end

    {:noreply, %{state | paired_devices: paired_devices}}
  end

  def handle_info({:device_update, %StatusChange{device_id: device_id, status: status}}, state) do
    %{paired_devices: paired_devices} = state

    paired_devices =
      case Map.get(paired_devices, device_id) do
        nil ->
          paired_devices

        paired_device_data ->
          Map.put(paired_devices, device_id, %{paired_device_data | status: status})
      end

    {:noreply, %{state | paired_devices: paired_devices}}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp get_devices_reply_to(), do: get_env(:exrabbitmq, :devices, [])[:device_exchange_in]
end
