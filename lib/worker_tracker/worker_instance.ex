defmodule WorkerTracker.WorkerInstance do
  defstruct name: "", active_workers: [], waiting_workers: [], conn: nil, connections: []

  alias WorkerTracker.{
    ActiveWorkerProcess,
    InstanceConnection,
    ProcessHelper,
    WaitingWorkerProcess,
    WorkerInstance
  }

  def from_instance_name(instance_name) do
    %WorkerInstance{name: instance_name}
    |> aquire_connection()
    |> refresh_instance()
  end

  def refresh_instance(%WorkerInstance{} = worker_instance) do
    worker_instance
    |> refresh_processes
    |> refresh_connections
  end

  def refresh_processes(%WorkerInstance{} = worker_instance) do
    processes = worker_instance |> get_all_processes()

    active_workers =
      processes
      |> ProcessHelper.filter_and_transform_process_list(
        "Processing",
        &ActiveWorkerProcess.parse_worker_process/1
      )

    waiting_workers =
      processes
      |> ProcessHelper.filter_and_transform_process_list(
        "Waiting",
        &WaitingWorkerProcess.parse_worker_process/1
      )

    %{worker_instance | active_workers: active_workers, waiting_workers: waiting_workers}
  end

  def refresh_connections(%WorkerInstance{} = worker_instance) do
    using_sudo = Application.get_env(:worker_tracker, :use_sudo)

    connections =
      worker_instance
      |> get_all_connections(using_sudo)
      |> Enum.map(&InstanceConnection.from_connection_string/1)

    %{worker_instance | connections: connections}
  end

  def terminate_process(%WorkerInstance{} = worker_instance, process_id, false = _use_sudo) do
    worker_instance.conn
    |> execute_command("kill -9 #{process_id}")
  end

  def terminate_process(%WorkerInstance{} = worker_instance, process_id, true = _use_sudo) do
    worker_instance.conn
    |> execute_command("sudo kill -9 #{process_id}")
  end

  defp get_all_processes(%WorkerInstance{} = worker_instance) do
    worker_instance.conn
    |> execute_command("ps aux")
    |> ProcessHelper.create_list_from_string()
  end

  defp get_all_connections(%WorkerInstance{} = worker_instance, true = _use_sudo) do
    worker_instance.conn
    |> execute_command("sudo lsof -i | grep -i established")
    |> ProcessHelper.create_list_from_string()
  end

  defp get_all_connections(%WorkerInstance{} = worker_instance, false = _use_sudo) do
    worker_instance.conn
    |> execute_command("lsof -i | grep -i established")
    |> ProcessHelper.create_list_from_string()
  end

  defp aquire_connection(%WorkerInstance{} = worker_instance) do
    {:ok, conn} = SSHEx.connect(ip: worker_instance.name)
    %{worker_instance | conn: conn}
  end

  defp execute_command(conn, command) do
    SSHEx.cmd!(conn, command)
  end
end
