defmodule WorkerTracker.Instance.Server do
  use GenServer

  import WorkerTracker.RegistryHelper, only: [notify: 2]

  alias WorkerTracker.Instance.Client

  def start_link(instance) do
    name = Client.build_name(instance)
    GenServer.start_link(__MODULE__, instance, name: name, timeout: :infinity)
  end

  def init(instance) do
    Process.send_after(self(), :send_notify, 1000)
    {:ok, instance}
  end

  def handle_call({:execute_command, command}, _from, instance) do
    result = Client.execute_command(instance, command)
    {:reply, result, instance}
  end

  def handle_cast({:execute_command, command}, _from, instance) do
    Client.execute_command(instance, command)
    {:noreply, instance}
  end

  def handle_info(:send_notify, instance) do
    notify("connection_ready", instance)
    {:noreply, instance}
  end
end
