defmodule WorkerServer do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_instances() do
    GenServer.call(__MODULE__, :get_instances)
  end

  def init(:ok) do
    Registry.register(WorkerTracker.Notifier, "connection_ready", self())
    {:ok, MapSet.new()}
  end

  def handle_call(:get_instances, _from, instances) do
    {:reply, MapSet.to_list(instances), instances}
  end

  def handle_info({:connection_ready, instance}, instances) do
    Task.start(fn ->
      DynamicSupervisor.start_child(WorkerSupervisor, {WorkerTracker.Server, instance})
    end)

    instances =
      instances
      |> MapSet.put(instance)

    {:noreply, instances}
  end
end
