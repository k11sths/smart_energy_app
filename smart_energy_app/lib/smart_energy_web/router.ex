defmodule SmartEnergyWeb.Router do
  use SmartEnergyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SmartEnergyWeb do
    pipe_through :api
  end
end
