defmodule WorkerTracker.WorkerInstance do
  defstruct name: "", active_workers: [], waiting_workers: [], conn: nil

  alias WorkerTracker.{ActiveWorkerProcess, ProcessHelper, WaitingWorkerProcess, WorkerInstance}

  def from_instance_name(instance_name) do
    worker_instance =
      %WorkerInstance{name: instance_name}
      |> aquire_connection()

    refresh_processes(worker_instance)
  end

  def refresh_processes(%WorkerInstance{} = worker_instance) do
    processes = worker_instance.conn |> get_all_processes()

    active_workers =
      processes
      |> ProcessHelper.filter_and_transform_process_list("Processing", &ActiveWorkerProcess.parse_worker_process/1)

    waiting_workers =
      processes
      |> ProcessHelper.filter_and_transform_process_list("Waiting", &WaitingWorkerProcess.parse_worker_process/1)

    %{worker_instance | active_workers: active_workers, waiting_workers: waiting_workers}
  end

  def terminate_process(%WorkerInstance{} = worker_instance, process_id, false = _use_sudo) do
    worker_instance.conn
    |> execute_command("kill -9 #{process_id}")
  end

  def terminate_process(%WorkerInstance{} = worker_instance, process_id, true = _use_sudo) do
    worker_instance.conn
    |> execute_command("sudo kill -9 #{process_id}")
  end

  defp get_all_processes(conn) do
    conn
    |> execute_command("ps aux")
    |> ProcessHelper.create_list_from_string()
  end

  defp aquire_connection(worker_instance) do
    {:ok, conn} = SSHEx.connect(ip: worker_instance.name)
    %{worker_instance | conn: conn}
  end

  defp execute_command(conn, command) do
    SSHEx.cmd!(conn, command)
  end
end
