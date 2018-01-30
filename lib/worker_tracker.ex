defmodule WorkerTracker do
  alias WorkerTracker.WorkerInstance

  defdelegate from_instance_name(worker), to: WorkerInstance
end
