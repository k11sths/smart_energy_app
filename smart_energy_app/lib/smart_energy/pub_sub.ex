defmodule SmartEnergy.PubSub do
  @moduledoc false

  @name :smart_energy_device_pubsub

  def subscribe_device_updates(device_id) do
    Phoenix.PubSub.subscribe(@name, "device_update_device_#{device_id}")
  end

  def publish_device_updates(%{device_id: device_id} = payload) do
    message = {:device_update, payload}

    Phoenix.PubSub.broadcast(@name, "device_update_device_#{device_id}", message)
  end
end
