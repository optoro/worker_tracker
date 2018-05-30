defmodule WorkerController do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Registry.register(WorkerTracker.Notifier, "connection_ready", self())
    {:ok, []}
  end

  def handle_info({:connection_ready, instance}, state) do
    DynamicSupervisor.start_child(DynamicSupervisor, {WorkerTracker.Server, instance})
    {:noreply, state}
  end
end
