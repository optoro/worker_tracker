defmodule WorkerTracker.WorkerInstance.Client do
  defstruct name: "", active_workers: [], waiting_workers: [], resque_pool_masters: []

  alias WorkerTracker.WorkerInstance.ActiveWorkerProcess
  alias WorkerTracker.WorkerInstance.WaitingWorkerProcess
  alias WorkerTracker.WorkerInstance.ResquePoolMasterProcess
  alias WorkerTracker.ProcessHelper

  def refresh_instance(%__MODULE__{} = worker_instance) do
    worker_instance
    |> get_all_processes()
    |> parse_resque_pool_masters(worker_instance)
    |> parse_active_workers(worker_instance)
    |> parse_waiting_workers(worker_instance)

    :ok
  end

  def get_instance(%__MODULE__{} = worker_instance) do
    worker_instance
    |> Map.put(:resque_pool_masters, retrieve_worker_registrations(worker_instance, "master"))
    |> Map.put(:active_workers, retrieve_worker_registrations(worker_instance))
    |> Map.put(:waiting_workers, retrieve_worker_registrations(worker_instance, "waiting"))
  end

  def terminate_process(%__MODULE__{} = worker_instance, process_id, false = _use_sudo) do
    worker_instance.name
    |> execute_command("kill -9 #{process_id}")
  end

  def terminate_process(%__MODULE__{} = worker_instance, process_id, true = _use_sudo) do
    worker_instance.name
    |> execute_command("sudo kill -9 #{process_id}")
  end

  defp get_all_processes(%__MODULE__{} = worker_instance) do
    worker_instance.name
    |> execute_command("ps -ejf")
    |> ProcessHelper.create_list_from_string()
  end

  defp parse_resque_pool_masters(processes, %__MODULE__{} = worker_instance) do
    processes
    |> ProcessHelper.filter_and_transform_process_list(
      "resque-pool-master",
      &ResquePoolMasterProcess.parse_master_process/1
    )
    |> update_worker_registrations(worker_instance.name, "master")

    processes
  end

  defp parse_active_workers(processes, %__MODULE__{} = worker_instance) do
    processes
    |> ProcessHelper.filter_and_transform_process_list(
      "Processing",
      &ActiveWorkerProcess.parse_worker_process/1
    )
    |> update_worker_registrations(worker_instance.name)

    processes
  end

  defp parse_waiting_workers(processes, %__MODULE__{} = worker_instance) do
    processes
    |> ProcessHelper.filter_and_transform_process_list(
      "Waiting",
      &WaitingWorkerProcess.parse_worker_process/1
    )
    |> update_worker_registrations(worker_instance.name, "waiting")
  end

  defp retrieve_worker_registrations(worker_instance, type \\ "active") do
    key = "#{worker_instance.name}:#{type}_workers"

    case Registry.lookup(WorkerTracker.WorkerProcesses, key) do
      [{_pid, processes}] ->
        processes

      _ ->
        []
    end
  end

  defp update_worker_registrations(processes, instance_name, type \\ "active") do
    registry_key = "#{instance_name}:#{type}_workers"

    case Registry.update_value(WorkerTracker.WorkerProcesses, registry_key, fn _x -> processes end) do
      :error ->
        Registry.register(WorkerTracker.WorkerProcesses, registry_key, processes)

      _ ->
        :ok
    end
  end

  defp execute_command(instance_name, command) do
    WorkerTracker.execute_command(instance_name, command)
  end
end
