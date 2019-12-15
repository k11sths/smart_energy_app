defmodule SmartEnergy.Devices.Models.DevicePing do
  @moduledoc false

  alias __MODULE__

  defstruct [:device_id, :timestamp]

  @type t :: %DevicePing{device_id: String, timestamp: pos_integer}

  def parse(%{"deviceId" => device_id}, timestamp) when is_binary(device_id),
    do: {:ok, %DevicePing{device_id: device_id, timestamp: timestamp}}

  def parse(_, _), do: {:error, :wrong_message_payload}
end
