defmodule SmartEnergy.Devices.Models.ConsumptionUpdate do
  @moduledoc false

  alias __MODULE__

  defstruct [:device_id, :consumption, :timestamp]

  @type t :: %ConsumptionUpdate{
          device_id: String,
          consumption: pos_integer,
          timestamp: pos_integer
        }

  def parse(%{"deviceId" => device_id, "consumption" => consumption}, timestamp)
      when is_binary(device_id),
      do:
        {:ok,
         %ConsumptionUpdate{device_id: device_id, consumption: consumption, timestamp: timestamp}}

  def parse(_, _), do: {:error, :wrong_message_payload}
end
