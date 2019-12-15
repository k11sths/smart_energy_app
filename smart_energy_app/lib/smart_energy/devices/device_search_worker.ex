defmodule SmartEnergy.Devices.DeviceSearchWorker do
  @moduledoc false

  use GenServer
  use ExRabbitMQ.Consumer

  require Logger

  alias SmartEnergy.PubSub
  alias SmartEnergy.Devices.Models.{ConsumptionUpdate, DevicePing, StatusChange}
  alias SmartEnergy.Devices.DeviceSearchWorker.Backend

  @module_name __MODULE__

  def start_link(_) do
    GenServer.start_link(@module_name, %{}, name: @module_name)
  end

  def get_available_devices(), do: GenServer.call(@module_name, :get_available_devices)

  def init(state) do
    new_state =
      :connection
      |> xrmq_init(:device_network_exchange, true, state)
      |> xrmq_extract_state()

    new_state = Map.put_new(new_state, :available_devices, %{})
    {:ok, new_state}
  end

  def handle_call(:get_available_devices, _, %{available_devices: available_devices} = state) do
    {:reply, available_devices, state}
  end

  def handle_info({:basic_consume_ok, %{consumer_tag: consumer_tag}}, state) do
    queue_name = ExRabbitMQ.State.get_session_config().queue
    Logger.debug("Successfully consuming from #{queue_name} with consumer_tag=#{consumer_tag}")

    {:noreply, state}
  end

  def handle_info(message, state) do
    Logger.debug("Received unknown message: #{message}")

    {:noreply, state}
  end

  def xrmq_basic_deliver(payload, rmq_meta, state) do
    new_state =
      with {:ok, device_message} <- Backend.parse(payload, rmq_meta) do
        actions_based_on_device_message(device_message, state)
      else
        _ ->
          state
      end

    rmq_meta.delivery_tag |> xrmq_basic_ack(state) |> xrmq_extract_state()

    {:noreply, new_state}
  end

  defp actions_based_on_device_message(
         %DevicePing{device_id: device_id, timestamp: timestamp},
         state
       ) do
    %{available_devices: available_devices} = state
    available_devices = Map.put(available_devices, device_id, timestamp)
    %{state | available_devices: available_devices}
  end

  defp actions_based_on_device_message(%ConsumptionUpdate{} = payload, state) do
    PubSub.publish_device_updates(payload)
    state
  end

  defp actions_based_on_device_message(%StatusChange{} = payload, state) do
    PubSub.publish_device_updates(payload)
    state
  end

  defp actions_based_on_device_message(_, state) do
    state
  end
end
