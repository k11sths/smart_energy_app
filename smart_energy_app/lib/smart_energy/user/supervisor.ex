defmodule SmartEnergy.User.Supervisor do
  @moduledoc false

  use DynamicSupervisor

  @supervisor __MODULE__

  @spec start_link(args :: any) :: Supervisor.on_start()
  def start_link(args) do
    DynamicSupervisor.start_link(@supervisor, args, name: @supervisor)
  end

  def start_child(args) do
    spec = %{
      :id => Keyword.get(args, :user_id),
      :start => {SmartEnergy.User.Worker, :start_link, [args]},
      :restart => :transient
    }

    {SmartEnergy.User.Worker, args}
    DynamicSupervisor.start_child(@supervisor, spec)
  end

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
