defmodule WorkerTracker do
  use Application

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
end
