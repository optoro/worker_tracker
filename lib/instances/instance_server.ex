defmodule WorkerTracker.InstanceServer do
  use GenServer

  alias __MODULE__
  alias WorkerTracker.RegistryHelper

  def start_link(instance) do
    name = build_name(instance)
    GenServer.start_link(__MODULE__, instance, name: name, timeout: :infinity)
  end

  def create_instances(instances) do
    instances
    |> Enum.map(&create_instance/1)
  end

  def execute_command(instance, command) do
    name = build_name(instance)
    GenServer.call(name, {:execute_command, command}, :infinity)
  end

  def instance_exists?(instance) do
    RegistryHelper.registry_contains?(WorkerTracker.InstanceRegistry, instance)
  end

  def init(instance) do
    case result = SSHEx.connect(ip: instance) do
      {:ok, _conn} ->
        RegistryHelper.dispatch(WorkerTracker.Notifier, "connection_ready", instance)

      _ ->
        IO.puts("Error Connecting to instance #{instance}")
    end

    result
  end

  def handle_call({:execute_command, command}, _from, conn) do
    result = SSHEx.cmd!(conn, command)
    {:reply, result, conn}
  end

  def handle_cast({:execute_command, command}, _from, conn) do
    SSHEx.cmd!(conn, command)
    {:noreply, conn}
  end

  defp build_name(instance) do
    RegistryHelper.name_via_registry(WorkerTracker.InstanceRegistry, instance)
  end

  defp create_instance(instance) do
    case instance_exists?(instance) do
      true ->
        {:ok, :already_exists}

      _ ->
        Task.Supervisor.start_child(
          WorkerTracker.TaskSupervisor,
          DynamicSupervisor,
          :start_child,
          [InstanceSupervisor, {InstanceServer, instance}]
        )
    end
  end
end
