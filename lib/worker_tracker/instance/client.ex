defmodule WorkerTracker.Instance.Client do
  alias WorkerTracker.InstanceRegistry

  import WorkerTracker.RegistryHelper,
    only: [
      registry_contains?: 2,
      name_via_registry: 2,
      notify: 2
    ]

  def create_connection(instance, module) do
    case result = module.connect(ip: instance) do
      {:ok, _conn} ->
        notify("connection_ready", instance)

      {:error, reason} ->
        IO.puts("Error Connecting to instance #{instance}: #{IO.inspect(reason)}")
    end

    result
  end

  def execute_command(conn, command, module) do
    module.cmd!(conn, command)
  end

  def instance_exists?(instance) do
    registry_contains?(InstanceRegistry, instance)
  end

  def build_name(instance) do
    name_via_registry(InstanceRegistry, instance)
  end
end
