defmodule WorkerTracker do
  use Application

  alias WorkerTracker.{InstanceSupervisor, Server, InstanceCollection}

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
    |> Enum.reject(&InstanceCollection.process_alive?/1)
    |> Enum.map(&Task.async(fn -> create_instance(&1) end))
    |> Enum.map(&Task.await/1)
  end

  def create_instance(instance) do
    DynamicSupervisor.start_child(InstanceSupervisor, {Server, instance})
  end

  def find_instance(instance) do
    GenServer.call(InstanceCollection, {:find_instance, instance})
  end

  def get_instances() do
    GenServer.call(InstanceCollection, :get_instances)
  end
end
