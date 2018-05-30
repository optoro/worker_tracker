defmodule WorkerTrackerSupervisor do
  use Supervisor

  def start_link() do
    IO.puts("Starting the WorkerTracker Supervisor...")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {Registry, [keys: :duplicate, name: WorkerTracker.Notifier]},
      {Registry, [keys: :unique, name: WorkerTracker.InstanceRegistry]},
      {Registry, [keys: :unique, name: WorkerTracker.WorkerRegistry]},
      {DynamicSupervisor, name: DynamicSupervisor, strategy: :one_for_one},
      {WorkerServer, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
