defmodule ResqueTracker.Client do
  defstruct [:mod, :instance, :conn]

  alias __MODULE__

  def create_connection(redis_instance, module) do
    {:ok, conn} =
      "redis://#{redis_instance}"
      |> module.start_link(port: 6379)

    %Client{mod: module, instance: redis_instance, conn: conn}
  end

  def get_worker_data(client, instance_name, worker_name, pid) do
    worker = worker_name |> transform_worker_name()

    {:ok, data} =
      execute_command(client, ["KEYS", "resque:worker:#{instance_name}:#{pid}:*#{worker}*"])

    data
    |> Enum.map(fn key -> {key, execute_command(client, ["GET", key])} end)
    |> Enum.map(fn {key, {:ok, value}} -> {key, value} end)
  end

  def get_failed_workers(client, count) do
    {:ok, length} = execute_command(client, ["LLEN", "resque:failed"])

    index = (length - count) |> Integer.to_string()

    {:ok, data} = execute_command(client, ["LRANGE", "resque:failed", index, "-1"])

    data |> Enum.reverse()
  end

  defp transform_worker_name(worker) do
    ~r/([A-Z][a-z]+)/
    |> Regex.scan(worker)
    |> Enum.flat_map(fn x -> Enum.uniq(x) end)
    |> Enum.map(&String.downcase/1)
    |> Enum.join("_")
  end

  defp execute_command(client, command_args) do
    client.conn
    |> client.mod.command(command_args)
  end
end
