defmodule SmartEnergy.Auth.Backend.Authentication do
  alias SmartEnergy.Auth.Backend.Encryption
  alias SmartEnergy.Auth.User
  alias SmartEnergy.Repo
  alias SmartEnergy.User.Manager, as: UserManager

  def sign_in(email, password) do
    user = Repo.get_by(User, email: String.downcase(email))

    case authenticate(user, password) do
      true -> {:ok, user}
      _ -> {:error, "Wrong email or password!"}
    end
  end

  def signed_in?(%{"session_guid" => session_guid}) do
    case UserManager.get_user_worker(session_guid) do
      {:ok, _worker_pid} -> true
      _ -> false
    end
  end

  def signed_in?(_), do: false

  defp authenticate(user, password) do
    case user do
      nil -> false
      _ -> Encryption.validate_password(password, user.password_hash)
    end
  end
end
