defmodule WorkerTracker do
  use Application

  alias WorkerTracker.{RegistryHelper, Server}

  def start(_type, _args) do
    IO.puts("Starting the WorkerTracker Application...")
    WorkerTrackerSupervisor.start_link()
  end

  def get_instance(instance) do
    instance
    |> find_instance()
    |> GenServer.call(:get_instance)
  end

  def refresh_instance(instance) do
    instance
    |> find_instance()
    |> GenServer.cast(:refresh_instance)
  end

  def terminate_instance_process(instance, process_id, payload \\ %{}) do
    using_sudo = Application.get_env(:worker_tracker, :use_sudo)

    instance
    |> find_instance()
    |> GenServer.call({:terminate_process, process_id, using_sudo})

    %{instance: instance, pid: process_id, timestamp: DateTime.utc_now()}
    |> Map.merge(payload)
    |> notify_terminated()
  end

  def create_instances(instances) do
    instances
    |> Enum.map(&Task.start(fn -> create_instance(&1) end))
  end

  def create_instance(instance) do
    case instance_exists?(instance) do
      true ->
        {:ok, :already_exists}

      _ ->
        DynamicSupervisor.start_child(InstanceSupervisor, {Server, instance})
    end
  end

  def find_instance(instance) do
    {pid, ^instance} =
      instance
      |> RegistryHelper.lookup()

    pid
  end

  def get_instances() do
    RegistryHelper.keys()
  end

  defp instance_exists?(instance) do
    RegistryHelper.registry_contains?(instance)
  end

  defp notify_terminated(payload) do
    RegistryHelper.dispatch(WorkerTracker.Notifier, "process_terminated", payload)
  end
end
