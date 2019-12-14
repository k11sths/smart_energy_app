defmodule SmartEnergy.Repo do
  use Ecto.Repo,
    otp_app: :smart_energy,
    adapter: Ecto.Adapters.Postgres
end
