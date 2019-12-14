defmodule SmartEnergyWeb.Router do
  use SmartEnergyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SmartEnergyWeb do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit]

    post "/users/sign_in", UserController, :sign_in
  end
end
