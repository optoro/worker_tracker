defmodule WorkerTracker.WorkerInstance.Client do
  defstruct name: "", active_workers: [], waiting_workers: []

  alias __MODULE__
  alias WorkerTracker.WorkerInstance.ActiveWorkerProcess
  alias WorkerTracker.WorkerInstance.WaitingWorkerProcess
  alias WorkerTracker.ProcessHelper

  def from_instance_name(instance_name) do
    %Client{name: instance_name}
    |> refresh_instance()
  end

  def refresh_instance(%Client{} = worker_instance) do
    worker_instance
    |> refresh_processes
  end

  def refresh_processes(%Client{} = worker_instance) do
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

  def terminate_process(%Client{} = worker_instance, process_id, false = _use_sudo) do
    worker_instance.name
    |> execute_command("kill -9 #{process_id}")
  end

  def terminate_process(%Client{} = worker_instance, process_id, true = _use_sudo) do
    worker_instance.name
    |> execute_command("sudo kill -9 #{process_id}")
  end

  defp get_all_processes(%Client{} = worker_instance) do
    worker_instance.name
    |> execute_command("ps -ejf")
    |> ProcessHelper.create_list_from_string()
  end

  defp execute_command(instance, command) do
    WorkerTracker.execute_command(instance, command)
  end
end
