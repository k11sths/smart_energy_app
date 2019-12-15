# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :smart_energy,
  ecto_repos: [SmartEnergy.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :smart_energy, SmartEnergyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Z/DYM2cWMA4Hk3fmAGe4jpd9ffdZogDVnKMb0U43GgMNWAeApgSMAmtr22CRNniV",
  render_errors: [view: SmartEnergyWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: SmartEnergy.PubSub, adapter: Phoenix.PubSub.PG2]

config :exrabbitmq, :device_network_exchange,
  queue: "",
  consume_opts: [no_ack: false],
  qos_opts: [prefetch_count: 1],
  declarations: [
    {:exchange,
     [
       name: "device_network_exchange",
       type: :fanout,
       opts: [durable: true]
     ]},
    {:queue,
     [
       name: "device_network_queue",
       opts: [auto_delete: false, durable: true],
       bindings: [
         [
           exchange: "device_network_exchange",
           opts: [
             routing_key: "*"
           ]
         ]
       ]
     ]}
  ]

config :exrabbitmq, :devices, devices_queue_in: "devices_queue_in"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
