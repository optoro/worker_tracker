defmodule WorkerServer do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_instances() do
    GenServer.call(__MODULE__, :get_instances)
  end

  def init(:ok) do
    Registry.register(WorkerTracker.Notifier, "worker_instance_ready", self())
    Registry.register(WorkerTracker.Notifier, "connection_ready", self())
    {:ok, []}
  end

  def handle_call(:get_instances, _from, instances) do
    {:reply, instances, instances}
  end

  def handle_info({:connection_ready, instance}, instances) do
    Task.start(fn ->
      DynamicSupervisor.start_child(DynamicSupervisor, {WorkerTracker.Server, instance})
    end)

    {:noreply, instances}
  end

  def handle_info({:worker_instance_ready, instance}, instances) do
    instances = [instance | instances]
    {:noreply, instances}
  end
end
