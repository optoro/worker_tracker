defmodule WorkerTracker do
  alias WorkerTracker.Server

  def new(worker) do
    GenServer.start_link(Server, worker)
  end

  def get_instance(worker_pid) do
    GenServer.call(worker_pid, :get_instance)
  end

  def refresh_processes(worker_pid) do
    GenServer.cast(worker_pid, :refresh_processes)
  end

end
