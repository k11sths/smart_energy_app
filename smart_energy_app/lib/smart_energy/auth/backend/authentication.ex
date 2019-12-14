defmodule SmartEnergy.Auth.Backend.Authentication do
  alias SmartEnergy.Auth.Backend.Encryption
  alias SmartEnergy.Auth.User
  alias SmartEnergy.Repo

  def sign_in(email, password) do
    user = Repo.get_by(User, email: String.downcase(email))

    case authenticate(user, password) do
      true -> {:ok, user}
      _ -> {:error, "Wrong email or password!"}
    end
  end

  ## Helper functions for view

  def current_user(conn) do
    id = Plug.Conn.get_session(conn, :current_user)
    if id, do: Repo.get(User, id)
  end

  def logged_in?(conn), do: !!current_user(conn)

  defp authenticate(user, password) do
    case user do
      nil -> false
      _ -> Encryption.validate_password(password, user.password_hash)
    end
  end
end
