defmodule SmartEnergy.User.Manager do
  @moduledoc false
  alias SmartEnergy.Registry
  alias SmartEnergy.User.Supervisor

  def get_user_worker(session_guid) do
    Registry.lookup(session_guid)
  end

  def spawn_user_worker(user) do
    session_guid = UUID.uuid4()

    with {:ok, _worker_pid} <-
           user
           |> get_worker_args(session_guid)
           |> Supervisor.start_child() do
      {:ok, session_guid}
    end
  end

  defp get_worker_args(%{id: user_id}, session_guid) do
    [
      key: session_guid,
      user_id: user_id,
      session_guid: session_guid
    ]
  end
end
