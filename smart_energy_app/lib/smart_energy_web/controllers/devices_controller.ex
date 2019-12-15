defmodule SmartEnergyWeb.DevicesController do
  @moduledoc false

  use SmartEnergyWeb, :controller

  alias SmartEnergy.Auth.Backend.Authentication
  alias SmartEnergy.Devices.DeviceSearchWorker

  action_fallback SmartEnergyWeb.FallbackController

  def get_available_devices(conn, params) do
    if Authentication.signed_in?(params) do
      get_available_devices = DeviceSearchWorker.get_available_devices()

      conn
      |> put_status(:ok)
      |> put_view(SmartEnergyWeb.DevicesView)
      |> render("get_available_devices.json", get_available_devices: get_available_devices)
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(SmartEnergyWeb.ErrorView)
      |> render("401.json", message: "Log in to get available devices!")
    end
  end

  def pair_device(conn, params) do
    # TODO: pair device in client's worker
  end
end
