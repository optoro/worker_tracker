defmodule WorkerTracker.Instance.Server do
  use GenServer

  alias WorkerTracker.Instance.Client

  def start_link(instance) do
    name = Client.build_name(instance)
    GenServer.start_link(__MODULE__, instance, name: name, timeout: :infinity)
  end

  def init(instance) do
    Client.create_connection(instance, SSHEx)
  end

  def handle_call({:execute_command, command}, _from, conn) do
    result = Client.execute_command(conn, command, SSHEx)
    {:reply, result, conn}
  end

  def handle_cast({:execute_command, command}, _from, conn) do
    Client.execute_command(conn, command, SSHEx)
    {:noreply, conn}
  end
end
