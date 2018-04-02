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
end
