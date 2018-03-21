defmodule WorkerTracker do
  use Application

  alias WorkerTracker.{InstanceSupervisor, Server, InstanceCollection}

  def start(_type, _args) do
    IO.puts("Starting the WorkerTracker application...")
    WorkerTracker.Supervisor.start_link()
  end

  def get_instance_processes(instance) do
    instance
    |> find_instance()
    |> GenServer.call(:get_instance)
  end

  def refresh_instance_processes(instance) do
    instance
    |> find_instance()
    |> GenServer.cast(:refresh_processes)
  end

  def terminate_instance_process(instance, process_id, use_sudo) do
      instance
      |> find_instance()
      |> GenServer.cast({:terminate_process, process_id, use_sudo})
  end

  def create_instances(instances) do
    instances
    |> Enum.map(&Task.async(fn -> create_instance(&1) end))
    |> Enum.map(&Task.await/1)
  end

  def create_instance(instance) do
    DynamicSupervisor.start_child(InstanceSupervisor, {Server, instance})
  end

  defp find_instance(instance) do
    GenServer.call(InstanceCollection, {:find_instance, instance})
  end
end
