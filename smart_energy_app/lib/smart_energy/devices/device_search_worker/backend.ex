defmodule SmartEnergy.Devices.DeviceSearchWorker.Backend do
  @moduledoc false

  alias SmartEnergy.Devices.Models.DevicePing

  def parse(payload, %{type: "Ping", timestamp: timestamp} = _rmq_meta)
      when is_integer(timestamp) and timestamp > 0 do
    with {:ok, message} <- Poison.decode(payload),
         {:ok, device_ping_model} <- DevicePing.parse(message, timestamp) do
      {:ok, device_ping_model}
    end
  end

  def parse(_, _) do
    {:error, :uknown_message}
  end
end
