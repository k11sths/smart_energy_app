defmodule SmartEnergy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      %{
        id: Phoenix.PubSub.PG2,
        start: {Phoenix.PubSub.PG2, :start_link, [:smart_energy_device_pubsub, []]}
      },
      ExRabbitMQ.Connection.Pool.Supervisor,
      SmartEnergy.Registry,
      SmartEnergy.Repo,
      SmartEnergyWeb.Endpoint,
      SmartEnergy.Devices.Supervisor,
      SmartEnergy.User.Supervisor,
      SmartEnergy.Devices.DeviceProducer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SmartEnergy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SmartEnergyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
