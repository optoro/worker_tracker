defmodule TmuxTracker do
  use GenServer

  alias TmuxTracker.Server

  defdelegate get_instance(instance), to: Server

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Registry.register(WorkerTracker.Notifier, "connection_ready", self())
    {:ok, nil}
  end

  def handle_info({:broadcast, instance}, _state) do
    DynamicSupervisor.start_child(TmuxSupervisor, {Server, instance})
    {:noreply, nil}
  end
end
