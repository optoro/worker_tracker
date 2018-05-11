defmodule ResqueTracker.Server do
  use GenServer

  # Client API

  def start_link(redis_instance) do
    GenServer.start_link(__MODULE__, redis_instance, name: __MODULE__)
  end

  # Server API

  def init(redis_instance) do
    {:ok, conn} =
      "redis://#{redis_instance}"
      |> Redix.start_link(port: 6379)

    {:ok, conn}
  end

  def handle_call({:get_worker_data, instance_name, pid, worker}, _from, conn) do
    {:ok, data} =
      conn
      |> Redix.command(["KEYS", "resque:worker:#{instance_name}:#{pid}:*#{worker}*"])

    result =
      data
      |> Enum.map(fn key -> {key, Redix.command(conn, ["GET", key])} end)
      |> Enum.map(fn {key, {:ok, value}} -> {key, value} end)

    {:reply, result, conn}
  end

  def handle_call({:get_failed_workers, count}, _from, conn) do
    {:ok, length} =
      conn
      |> Redix.command(["LLEN", "resque:failed"])

    index =
      (length - count)
      |> Integer.to_string()

    {:ok, data} =
      conn
      |> Redix.command(["LRANGE", "resque:failed", index, "-1"])

    data = data |> Enum.reverse()

    {:reply, data, conn}
  end
end
