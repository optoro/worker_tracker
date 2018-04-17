defmodule WorkerTracker.RegistryHelper do
  @moduledoc ~S"""
    A collection of helpers to manipulate registries.
  """

  @typedoc "The registry identifier"
  @type registry :: atom

  @doc ~S"""
    Register an instance with the WorkerTracker Registry."
  """
  @spec register(String.t()) :: {:error, {:already_registered, pid()}} | {:ok, pid()}
  def register(instance) do
    Registry.register(WorkerTracker.Registry, "workers", instance)
  end

  @doc ~S"""
    Lookup an instance in the WorkerTracker Registry.
  """
  @spec lookup(String.t()) :: {pid(), String.t()}
  def lookup(instance) do
    Registry.match(WorkerTracker.Registry, "workers", instance)
    |> List.first()
  end

  @doc ~S"""
    Get all registered instances from the WorkerTracker Registry.
  """
  @spec keys() :: [String.t()]
  def keys() do
    Registry.lookup(WorkerTracker.Registry, "workers")
    |> Enum.map(fn {_pid, instance} -> instance end)
  end

  @doc ~S"""
    Determine if the WorkerTracker Registry contains the given `instance`.
  """
  @spec registry_contains?(String.t()) :: true | false
  def registry_contains?(instance) do
    case Registry.match(WorkerTracker.Registry, "workers", instance) do
      [{_pid, ^instance}] -> true
      _ -> false
    end
  end

  @doc ~S"""
    Send a `payload` to the given `channel` for all subscribers of the `registry`.
  """
  @spec dispatch(registry, String.t(), any()) :: :ok
  def dispatch(registry, channel, payload) do
    Registry.dispatch(registry, channel, fn entries ->
      for {pid, _name} <- entries do
        send(pid, {String.to_atom(channel), payload})
      end
    end)
  end
end
