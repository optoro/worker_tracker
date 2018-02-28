defmodule WorkerTracker.Server do
  use GenServer

  alias WorkerTracker.WorkerInstance

  def init(worker) do
    worker_instance = WorkerInstance.from_instance_name(worker)
    {:ok, worker_instance}
  end

  def handle_call(:get_instance, _from, worker_instance) do
    {:reply, worker_instance, worker_instance}
  end

  def handle_cast(:refresh_processes, worker_instance) do
    worker_instance = WorkerInstance.refresh_processes(worker_instance)
    {:noreply, worker_instance}
  end

  def handle_cast({:terminate_process, process_id, use_sudo}, worker_instance) do
    WorkerInstance.terminate_process(worker_instance, process_id, use_sudo)
    worker_instance = WorkerInstance.refresh_processes(worker_instance)
    {:noreply, worker_instance}
  end

end
