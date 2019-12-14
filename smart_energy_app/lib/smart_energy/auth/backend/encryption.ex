defmodule SmartEnergy.Auth.Backend.Encryption do
  def hash_password(password), do: :sha256 |> :crypto.hash(password) |> Base.encode16()

  def validate_password(password, hash),
    do: :sha256 |> :crypto.hash(password) |> Base.encode16() == hash
end
