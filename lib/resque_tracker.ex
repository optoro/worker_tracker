defmodule ResqueTracker do
  alias ResqueTracker.Server

  def new(redis_instance) do
    DynamicSupervisor.start_child(WorkerSupervisor, {Server, redis_instance})
  end

  def get_worker_data(instance_name, pid, worker) do
    worker_name =
      worker
      |> transform_worker_name()

    GenServer.call(Server, {:get_worker_data, instance_name, pid, worker_name})
  end

  def get_worker_failures(count) do
    GenServer.call(Server, {:get_failed_workers, count})
  end

  defp transform_worker_name(worker) do
    ~r/([A-Z][a-z]+)/
    |> Regex.scan(worker)
    |> Enum.flat_map(fn x -> Enum.uniq(x) end)
    |> Enum.map(&String.downcase/1)
    |> Enum.join("_")
  end
end
