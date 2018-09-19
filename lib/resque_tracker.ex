defmodule ResqueTracker do
  alias ResqueTracker.Server

  def new(redis_instance) do
    DynamicSupervisor.start_child(InstanceSupervisor, {Server, redis_instance})
  end

  def get_worker_data(instance_name, pid, worker) do
    GenServer.call(Server, {:get_worker_data, instance_name, pid, worker})
  end

  def get_worker_failures(count) do
    GenServer.call(Server, {:get_failed_workers, count})
  end
end
