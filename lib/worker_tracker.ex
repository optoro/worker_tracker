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

  defdelegate get_instances(), to: WorkerController

  def create_instances(instances) do
    instances
    |> Enum.map(&create_instance/1)
  end

  def create_instance(instance) do
    case instance_exists?(instance) do
      true ->
        {:ok, :already_exists}

      _ ->
        Task.start(fn ->
          DynamicSupervisor.start_child(DynamicSupervisor, {InstanceServer, instance})
        end)
    end
  end

  defp instance_exists?(instance) do
    WorkerTracker.InstanceServer.instance_exists?(instance)
  end
end
