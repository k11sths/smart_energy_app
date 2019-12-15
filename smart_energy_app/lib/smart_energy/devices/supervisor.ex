defmodule SmartEnergy.Devices.Supervisor do
  @moduledoc false

  use Supervisor

  @module_name __MODULE__

  def start_link(args) do
    Supervisor.start_link(@module_name, args, name: @module_name)
  end

  def init(_) do
    children = [
      SmartEnergy.Devices.DeviceSearchWorker
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
