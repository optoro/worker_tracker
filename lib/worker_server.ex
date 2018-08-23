defmodule WorkerServer do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_instances() do
    Registry.lookup(WorkerTracker.CollectionRegistry, "instances")
    |> Enum.map(fn {_pid, instance} -> instance end)
  end

  def init(:ok) do
    Registry.register(WorkerTracker.Notifier, "worker_instance_ready", self())
    Registry.register(WorkerTracker.Notifier, "connection_ready", self())
    {:ok, nil}
  end

  def handle_info({:connection_ready, instance}, instances) do
    Task.start(fn ->
      DynamicSupervisor.start_child(WorkerSupervisor, {WorkerTracker.Server, instance})
    end)

    {:noreply, instances}
  end

  def handle_info({:worker_instance_ready, instance}, instances) do
    instances = MapSet.put(instances, instance)
    {:noreply, instances}
  end
end
