defmodule SmartEnergy.Devices.Models.StatusChange do
  @moduledoc false

  alias __MODULE__

  defstruct [:device_id, :status, :timestamp]

  @type t :: %StatusChange{
          device_id: String,
          status: pos_integer,
          timestamp: pos_integer
        }

  def parse(%{"deviceId" => device_id, "status" => status}, timestamp)
      when is_binary(device_id),
      do: {:ok, %StatusChange{device_id: device_id, status: status, timestamp: timestamp}}

  def parse(_, _), do: {:error, :wrong_message_payload}
end
