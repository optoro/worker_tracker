defmodule WorkerTracker do
  alias WorkerTracker.WorkerInstance

  defdelegate get_active_workers(worker), to: WorkerInstance
end
