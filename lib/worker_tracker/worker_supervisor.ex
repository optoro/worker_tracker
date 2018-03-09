defmodule WorkerTracker.WorkerSupervisor do
  use Supervisor

  def init(worker) do
    children = [
      {WorkerTracker.Server, worker}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
