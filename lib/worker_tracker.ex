defmodule WorkerTracker do
  use Application

  alias WorkerTracker.InstanceServer

  def start(_type, _args) do
    IO.puts("Starting the WorkerTracker Application...")
    WorkerTrackerSupervisor.start_link()
  end

  defdelegate get_instance(instance), to: WorkerTracker.Server
  defdelegate refresh_instance(instance), to: WorkerTracker.Server

  defdelegate terminate_instance_process(instance, process_id, payload \\ %{}),
    to: WorkerTracker.Server

  defdelegate get_instances(), to: WorkerServer

  defdelegate create_instances(instances), to: WorkerTracker.InstanceServer

  defp instance_exists?(instance) do
    WorkerTracker.InstanceServer.instance_exists?(instance)
  end
end
