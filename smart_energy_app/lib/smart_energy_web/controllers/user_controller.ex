defmodule SmartEnergyWeb.UserController do
  use SmartEnergyWeb, :controller

  alias SmartEnergy.Auth
  alias SmartEnergy.Auth.User
  alias SmartEnergy.Auth.Backend.Authentication
  alias SmartEnergy.User.Manager, as: UserManager

  action_fallback SmartEnergyWeb.FallbackController

  def index(conn, _params) do
    users = Auth.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, decoded_user_params} <- Poison.decode(user_params),
         {:ok, %User{} = user} <- Auth.create_user(decoded_user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Auth.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Auth.get_user!(id)

    with {:ok, %User{} = user} <- Auth.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Auth.get_user!(id)

    with {:ok, %User{}} <- Auth.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Authentication.sign_in(email, password) do
      {:ok, user} ->
        {:ok, session_guid} = UserManager.spawn_user_worker(user)
        user = Map.put(user, :session_guid, session_guid)

        conn
        |> put_status(:ok)
        |> put_view(SmartEnergyWeb.UserView)
        |> render("sign_in.json", user: user)

      {:error, message} ->
        conn
        |> put_status(:unauthorized)
        |> put_view(SmartEnergyWeb.ErrorView)
        |> render("401.json", message: message)
    end
  end
end
