defmodule WorkerTracker.WorkerInstance do
  defstruct name: "", active_workers: [], waiting_workers: [], conn: nil

  alias WorkerTracker.{ActiveWorkerProcess, WaitingWorkerProcess, WorkerInstance}

  def from_instance_name(instance_name) do
    worker_instance =
      %WorkerInstance{name: instance_name}
      |> aquire_connection()

    refresh_processes(worker_instance)
  end

  def refresh_processes(%WorkerInstance{} = worker_instance) do
    processes = worker_instance.conn |> get_all_processes()
    active_workers = processes |> filter_active_workers()
    waiting_workers = processes |> filter_waiting_workers()

    %{worker_instance | active_workers: active_workers, waiting_workers: waiting_workers}
  end

  def terminate_process(%WorkerInstance{} = worker_instance, process_id, false = use_sudo) do
    worker_instance.conn
    |> execute_command("kill -9 #{process_id}")
  end

  def terminate_process(%WorkerInstance{} = worker_instance, process_id, true = use_sudo) do
    worker_instance.conn
    |> execute_command("sudo kill -9 #{process_id}")
  end

  defp get_all_processes(conn) do
    conn
    |> execute_command("ps aux")
    |> create_process_list()
  end

  defp aquire_connection(worker_instance) do
    {:ok, conn} = SSHEx.connect(ip: worker_instance.name)
    %{worker_instance | conn: conn}
  end

  defp execute_command(conn, command) do
    SSHEx.cmd!(conn, command)
  end

  defp create_process_list(process_string) do
    process_string
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
  end

  defp filter_active_workers(process_list) do
    process_list
    |> filter_workers("Processing", &ActiveWorkerProcess.parse_worker_process/1)
  end

  defp filter_waiting_workers(process_list) do
    process_list
    |> filter_workers("Waiting", &WaitingWorkerProcess.parse_worker_process/1)
  end

  defp filter_workers(process_list, filter_string, parser_function) do
    process_list
    |> Enum.filter(&String.contains?(&1, filter_string))
    |> Enum.map(&parser_function.(&1))
  end
end
