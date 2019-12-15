defmodule SmartEnergy.Registry do
  @moduledoc false

  @registry __MODULE__

  def child_spec(_) do
    Registry.child_spec(name: @registry, keys: :unique)
  end

  def via(key) do
    {:via, Registry, {@registry, key}}
  end

  def lookup(key) do
    case Registry.lookup(@registry, key) do
      [{pid, _}] -> {:ok, pid}
      _ -> {:error, :not_found}
    end
  end
end
