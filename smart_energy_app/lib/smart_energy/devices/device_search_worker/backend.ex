defmodule SmartEnergy.Devices.DeviceSearchWorker.Backend do
  @moduledoc false

  alias SmartEnergy.Devices.Models.{ConsumptionUpdate, StatusChange, DevicePing}

  def parse(payload, %{type: "Ping", timestamp: timestamp} = _rmq_meta)
      when is_integer(timestamp) and timestamp > 0 do
    with {:ok, message} <- Poison.decode(payload),
         {:ok, device_ping_model} <- DevicePing.parse(message, timestamp) do
      {:ok, device_ping_model}
    end
  end

  def parse(payload, %{type: "ConsumptionUpdate", timestamp: timestamp} = _rmq_meta)
      when is_integer(timestamp) and timestamp > 0 do
    with {:ok, message} <- Poison.decode(payload),
         {:ok, consumption_update_model} <-
           ConsumptionUpdate.parse(message, timestamp) do
      {:ok, consumption_update_model}
    end
  end

  def parse(payload, %{type: "StatusChange", timestamp: timestamp} = _rmq_meta)
      when is_integer(timestamp) and timestamp > 0 do
    with {:ok, message} <- Poison.decode(payload),
         {:ok, device_ping_model} <- StatusChange.parse(message, timestamp) do
      {:ok, device_ping_model}
    end
  end

  def parse(_, _) do
    {:error, :uknown_message}
  end
end
