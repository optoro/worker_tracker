defmodule WorkerTracker do
  use Application

  def start(_type, _args) do
    IO.puts("Starting the WorkerTracker Application...")
    WorkerTrackerSupervisor.start_link()
  end

  def create_instances(instances) do
    instances
    |> Enum.map(&create_instance/1)
  end

  def create_instance(instance) do
    case instance_exists?(instance) do
      true ->
        {:ok, :already_exists}

      _ ->
        Task.Supervisor.start_child(
          WorkerTracker.TaskSupervisor,
          DynamicSupervisor,
          :start_child,
          [InstanceSupervisor, {WorkerTracker.Instance.Server, instance}]
        )
    end
  end

  def execute_command(instance, command) do
    instance
    |> build_name()
    |> GenServer.call({:execute_command, command}, :infinity)
  end

  defdelegate get_instance(instance), to: WorkerTracker.WorkerInstance.Server
  defdelegate refresh_instance(instance), to: WorkerTracker.WorkerInstance.Server

  defdelegate terminate_instance_process(instance, process_id, payload \\ %{}),
    to: WorkerTracker.WorkerInstance.Server

  defdelegate get_instances(), to: WorkerServer

  defdelegate build_name(instance), to: WorkerTracker.Instance.Client
  defdelegate instance_exists?(instance), to: WorkerTracker.Instance.Client
end
