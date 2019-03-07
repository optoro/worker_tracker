defmodule TmuxTracker.Server do
  use GenServer

  alias TmuxTracker.Client

  @refresh_interval :timer.seconds(10)

  def start_link(instance) do
    name = name_via_registry(instance)
    GenServer.start_link(__MODULE__, instance, name: name)
  end

  def get_instance(instance) do
    name = name_via_registry(instance)
    GenServer.call(name, :get_instance)
  end

  def init(instance) do
    client = instance |> Client.create()
    Process.send_after(self(), :update_client, @refresh_interval)
    {:ok, client}
  end

  def handle_call(:get_instance, _from, client) do
    {:reply, client, client}
  end

  def handle_info(:update_client, client) do
    client = client.instance |> Client.create()
    Process.send_after(self(), :update_client, @refresh_interval)
    {:noreply, client}
  end

  defp name_via_registry(name) do
    {:via, Registry, {WorkerTracker.TmuxRegistry, name}}
  end
end
