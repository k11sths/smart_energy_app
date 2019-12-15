defmodule SmartEnergyWeb.Router do
  use SmartEnergyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SmartEnergyWeb do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit]
    post "/users/sign_in", UserController, :sign_in

    get "/devices/get", DevicesController, :get_available_devices
    get "/devices/pair/get", DevicesController, :get_paired_devices
    post "/devices/pair", DevicesController, :pair_device

    # get "/device/get", DevicesController, :get_device_data
    # post "/device/status", DevicesController, :pair_device
  end
end
