defmodule SmartEnergy.User.Worker do
  @moduledoc false

  use GenServer

  alias SmartEnergy.Registry

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

  def init(args) do
    user_id = Keyword.get(args, :user_id)
    session_guid = Keyword.get(args, :session_guid)
    {:ok, %{user_id: user_id, session_guid: session_guid, paired_devices: %{}}}
  end

  def handle_cast({:pair_new_device, device_id}, state) do
    # TODO: pubsub
    %{paired_devices: paired_devices} = state

    paired_devices =
      if Map.get(paired_devices, device_id) === nil do
        # TODO: pairing handshake? RPC
        Map.put(paired_devices, device_id, %{consumption: 0, state: nil})
      else
        paired_devices
      end

    {:noreply, %{state | paired_devices: paired_devices}}
  end

  def handle_call(:get_paired_devices, _, %{paired_devices: paired_devices} = state) do
    {:reply, paired_devices, state}
  end
end
