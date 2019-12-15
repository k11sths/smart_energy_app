defmodule SmartEnergy.Devices.DeviceSearchWorker do
  @moduledoc false

  use GenServer
  use ExRabbitMQ.Consumer

  require Logger

  alias SmartEnergy.Devices.Models.DevicePing
  alias SmartEnergy.Devices.DeviceSearchWorker.Backend

  @module_name __MODULE__

  def start_link(_) do
    GenServer.start_link(@module_name, %{}, name: @module_name)
  end

  # def get_available_devices(), do: GenServer.cast(self(), :get_available_devices)

  def init(state) do
    new_state =
      :connection
      |> xrmq_init(:device_network_exchange, true, state)
      |> xrmq_extract_state()

    new_state = Map.put_new(new_state, :available_devices, %{})
    {:ok, new_state}
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
        %{available_devices: available_devices} = state
        %DevicePing{device_id: device_id, timestamp: timestamp} = device_message
        available_devices = Map.put(available_devices, device_id, timestamp)
        %{state | available_devices: available_devices}
      else
        _ ->
          state
      end

    rmq_meta.delivery_tag |> xrmq_basic_ack(state) |> xrmq_extract_state()

    {:noreply, new_state}
  end
end
