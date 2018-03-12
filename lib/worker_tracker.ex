defmodule WorkerTracker do

  def start_link(worker) do
    Supervisor.start_link(WorkerTracker.Supervisor, worker)
  end

  def get_instance(worker_pid) do
    pid = get_child_pid(worker_pid)
    GenServer.call(pid, :get_instance)
  end

  def refresh_processes(worker_pid) do
    pid = get_child_pid(worker_pid)
    GenServer.cast(pid, :refresh_processes)
  end

  def terminate_process(worker_pid, process_id, use_sudo) do
    pid = get_child_pid(worker_pid)
    GenServer.cast(pid, {:terminate_process, process_id, use_sudo})
  end

  defp get_child_pid(sup_pid) do
    [{module, child_pid, :worker, [module]}] = Supervisor.which_children(sup_pid)
    child_pid
  end
end
