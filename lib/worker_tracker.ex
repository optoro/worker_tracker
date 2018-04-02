defmodule WorkerTracker do
  use Application

  alias WorkerTracker.{InstanceSupervisor, RegistryHelper, Server}

  def start(_type, _args) do
    IO.puts("Starting the WorkerTracker Application...")
    WorkerTracker.Supervisor.start_link()
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

  def terminate_instance_process(instance, process_id) do
    using_sudo = Application.get_env(:worker_tracker, :use_sudo)

    instance
    |> find_instance()
    |> GenServer.cast({:terminate_process, process_id, using_sudo})
  end

  def create_instances(instances) do
    instances
    |> Enum.map(&Task.async(fn -> create_instance(&1) end))
    |> Enum.map(&Task.await/1)
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
    {pid, _instance_name} =
      instance
      |> RegistryHelper.lookup()

    pid
  end

  def get_instances() do
    RegistryHelper.keys()
  end

  defp instance_exists?(instance) do
    get_instances()
    |> Enum.any?(&(&1 == instance))
  end
end
