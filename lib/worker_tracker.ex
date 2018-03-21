defmodule WorkerTracker do
  use Application

  alias WorkerTracker.{InstanceSupervisor, Server, WorkerCollection}

  def start(_type, _args) do
    IO.puts("Starting the WorkerTracker application...")
    WorkerTracker.Supervisor.start_link()
  end

  def get_instance_processes(worker) do
    worker
    |> find_worker()
    |> GenServer.call(:get_instance)
  end

  def refresh_instance_processes(worker) do
    worker
    |> find_worker()
    |> GenServer.cast(:refresh_processes)
  end

  def terminate_instance_process(worker, process_id, use_sudo) do
    worker
    |> find_worker()
    |> GenServer.cast({:terminate_process, process_id, use_sudo})
  end

  def create_workers(workers) do
    workers
    |> Enum.map(&Task.async(fn -> create_worker(&1) end))
    |> Enum.map(&Task.await/1)
  end

  def create_worker(worker) do
    DynamicSupervisor.start_child(InstanceSupervisor, {Server, worker})
  end

  defp find_worker(worker) do
    GenServer.call(WorkerCollection, {:find_worker, worker})
  end
end
