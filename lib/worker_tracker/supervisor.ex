defmodule WorkerTracker.Supervisor do
  use Supervisor

  alias WorkerTracker.InstanceSupervisor

  def start_link() do
    IO.puts("Starting the WorkerTracker Supervisor...")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {Registry, [keys: :duplicate, name: WorkerTracker.Registry]},
      {DynamicSupervisor, name: InstanceSupervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
