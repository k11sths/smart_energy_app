defmodule SmartEnergyWeb.DevicesController do
  @moduledoc false

  use SmartEnergyWeb, :controller

  alias SmartEnergy.Auth.Backend.Authentication
  alias SmartEnergy.Devices.DeviceSearchWorker
  alias SmartEnergy.User.Manager, as: UserManager
  alias SmartEnergy.User.Worker


  action_fallback SmartEnergyWeb.FallbackController

  def get_available_devices(conn, params) do
    if Authentication.signed_in?(params) do
      get_available_devices = DeviceSearchWorker.get_available_devices()

      conn
      |> put_status(:ok)
      |> put_view(SmartEnergyWeb.DevicesView)
      |> render("get_available_devices.json", get_available_devices: get_available_devices)
    else
      reply_unauthorized(conn)
    end
  end

  def pair_device(conn, %{"session_guid" => session_guid, "device_id" => device_id}) do
    case UserManager.get_user_worker(session_guid) do
      {:ok, worker_pid} ->
        Worker.pair_new_device(worker_pid, device_id)

        conn
        |> put_status(:ok)
        |> put_view(SmartEnergyWeb.DevicesView)
        |> render("pair_device_success.json", device_id: device_id)

      _ ->
        reply_unauthorized(conn)
    end
  end

  def get_paired_devices(conn, %{"session_guid" => session_guid}) do
    case UserManager.get_user_worker(session_guid) do
      {:ok, worker_pid} ->
        paired_devices = Worker.get_paired_devices(worker_pid)

        conn
        |> put_status(:ok)
        |> put_view(SmartEnergyWeb.DevicesView)
        |> render("get_paired_devices.json", paired_devices: paired_devices)

      _ ->
        reply_unauthorized(conn)
    end
  end

  def get_device_data(conn, %{"session_guid" => session_guid, "device_id" => device_id}) do
    case UserManager.get_user_worker(session_guid) do
      {:ok, worker_pid} ->
        paired_device = Worker.get_device_data(worker_pid, device_id)

        conn
        |> put_status(:ok)
        |> put_view(SmartEnergyWeb.DevicesView)
        |> render("get_paired_device_data.json", paired_device: paired_device)

      _ ->
        reply_unauthorized(conn)
    end
  end

  def change_device_status(conn, %{
        "session_guid" => session_guid,
        "device_id" => device_id,
        "status" => status
      }) do
    case UserManager.get_user_worker(session_guid) do
      {:ok, worker_pid} ->
        paired_device_data = Worker.change_device_status(worker_pid, device_id, status)

        conn
        |> put_status(:ok)
        |> put_view(SmartEnergyWeb.DevicesView)
        |> render("change_device_status.json",
          device_id: device_id,
          status: Map.get(paired_device_data, :status)
        )

      _ ->
        reply_unauthorized(conn)
    end
  end

  defp reply_unauthorized(conn) do
    conn
    |> put_status(:unauthorized)
    |> put_view(SmartEnergyWeb.ErrorView)
    |> render("401.json", message: "Sign in required!")
  end
end
