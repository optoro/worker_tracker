defmodule WorkerTracker do
  alias WorkerTracker.WorkerInstance

  defdelegate from_instance_name(worker_name), to: WorkerInstance
  defdelegate refresh_processes(worker_instance), to: WorkerInstance
end
