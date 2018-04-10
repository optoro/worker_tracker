defmodule WorkerTracker.RegistryHelper do
  def register(instance) do
    Registry.register(WorkerTracker.Registry, "workers", instance)
  end

  def lookup(instance) do
    Registry.lookup(WorkerTracker.Registry, "workers")
    |> Enum.filter(fn {_pid, instance_name} -> instance == instance_name end)
    |> List.first()
  end

  def keys() do
    Registry.lookup(WorkerTracker.Registry, "workers")
    |> Enum.map(fn {_pid, instance} -> instance end)
  end

  def dispatch(registry, channel, payload) do
    Registry.dispatch(registry, channel, fn entries ->
      for {pid, name} <- entries do
        send(pid, {String.to_atom(channel), payload})
      end
    end)
  end
end
