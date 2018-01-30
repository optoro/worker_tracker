defmodule WorkerTracker.WorkerInstance do
  defstruct name: "", active_workers: [], waiting_workers: []

  alias WorkerTracker.{ActiveWorkerProcess, WaitingWorkerProcess, WorkerInstance}

  def from_instance_name(instance_name) do
    processes = instance_name
                |> get_all_processes()

    active_workers = processes
                     |> filter_active_workers()

    %WorkerInstance{ name: instance_name, active_workers: active_workers }
  end

  def get_all_processes(name) do
    name
    |> get_processes("ps aux")
    |> create_process_list()
  end

  defp get_processes(worker, command) do
    {:ok, conn} = SSHEx.connect(ip: worker)
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

  defp filter_workers(process_list, filter_string, parser_function) do
    process_list
    |> Enum.filter(&String.contains?(&1, filter_string))
    |> Enum.map(&parser_function.(&1))
  end
end
