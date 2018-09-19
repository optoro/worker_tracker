defmodule WorkerTrackerSupervisor do
  use Supervisor

  def start_link() do
    IO.puts("Starting the WorkerTracker Supervisor...")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {Registry, [keys: :duplicate, name: WorkerTracker.Notifier]},
      {Registry, [keys: :duplicate, name: WorkerTracker.CollectionRegistry]},
      {Registry, [keys: :unique, name: WorkerTracker.InstanceRegistry]},
      {Registry, [keys: :unique, name: WorkerTracker.WorkerRegistry]},
      {DynamicSupervisor, name: InstanceSupervisor, strategy: :one_for_one, max_restarts: 100},
      {DynamicSupervisor, name: WorkerSupervisor, strategy: :one_for_one, max_restarts: 1000},
      {Task.Supervisor, name: WorkerTracker.TaskSupervisor},
      {WorkerServer, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
