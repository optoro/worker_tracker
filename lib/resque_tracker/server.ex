defmodule ResqueTracker.Server do
  use GenServer

  alias ResqueTracker.Client

  # Client API

  def start_link(redis_instance) do
    GenServer.start_link(__MODULE__, redis_instance, name: __MODULE__, timeout: 10_000)
  end

  # Server API

  def init(redis_instance) do
    client = Client.create_connection(redis_instance, Redix)
    {:ok, client}
  end

  def handle_call({:get_worker_data, instance_name, pid, worker}, _from, client) do
    result =
      client
      |> Client.get_worker_data(instance_name, worker, pid)

    {:reply, result, client}
  end

  def handle_call({:get_failed_workers, count}, _from, client) do
    result =
      client
      |> Client.get_failed_workers(count)

    {:reply, result, client}
  end
end
