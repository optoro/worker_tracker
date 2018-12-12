defmodule WorkerTracker.Instance.Client do
  alias WorkerTracker.InstanceRegistry

  import WorkerTracker.RegistryHelper,
    only: [
      registry_contains?: 2,
      name_via_registry: 2
    ]

  def execute_command(instance, command) do
    {data, _exit_code} = System.cmd("ssh", [instance, command])
    data
  end

  def instance_exists?(instance) do
    registry_contains?(InstanceRegistry, instance)
  end

  def build_name(instance) do
    name_via_registry(InstanceRegistry, instance)
  end
end
