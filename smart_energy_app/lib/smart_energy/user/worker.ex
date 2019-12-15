defmodule SmartEnergy.User.Worker do
  @moduledoc false

  use GenServer

  alias SmartEnergy.Registry

  @module_name __MODULE__

  def start_link(args) do
    with key when not is_nil(key) <- Keyword.get(args, :key),
         name <- Registry.via(key) do
      GenServer.start_link(@module_name, args, name: name)
    else
      _ -> {:error, :invalid_args}
    end
  end

  def init(args) do
    user_id = Keyword.get(args, :user_id)
    session_guid = Keyword.get(args, :session_guid)
    {:ok, %{user_id: user_id, session_guid: session_guid, paired_devices: %{}}}
  end
end
