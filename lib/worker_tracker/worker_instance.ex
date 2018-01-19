defmodule WorkerTracker.WorkerInstance do
  alias WorkerTracker.ActiveWorkerProcess

  def get_active_workers(worker) do
    worker
    |> get_processes(ActiveWorkerProcess.process_command_string())
    |> parse_processes_from_string(worker)
  end

  defp get_processes(worker, command) do
    {:ok, conn} = SSHEx.connect(ip: worker)
    SSHEx.cmd!(conn, command)
  end

  defp parse_processes_from_string(process_string, worker) do
    process_string
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&ActiveWorkerProcess.parse_from_process_string(&1, worker))
  end
end
