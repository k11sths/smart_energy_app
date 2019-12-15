defmodule SmartEnergy.Devices.DeviceProducer do
  @moduledoc false

  use GenServer
  use ExRabbitMQ.Producer, GenServer

  require Logger

  @name __MODULE__

  def start_link(_args) do
    GenServer.start_link(@name, %{}, name: @name)
  end

  def init(state) do
    with {:error, reason, _new_state} <- xrmq_init(:connection, state) do
      {:error, reason}
    end
  end

  def publish(payload, reply_to) do
    GenServer.call(@name, {:publish, payload, reply_to})
  end

  def handle_call({:publish, payload, reply_to}, _, state) do
    formatted_payload = Poison.encode!(payload, format_keys: :camel_case)
    res = xrmq_basic_publish(formatted_payload, reply_to, "", type: "ChangeStatus")

    {:reply, res, state}
  end
end
