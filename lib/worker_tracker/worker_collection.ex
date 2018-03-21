defmodule WorkerTracker.WorkerCollection do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add_worker(worker, pid) do
    GenServer.call(__MODULE__, {:add_worker, pid, worker})
  end

  def find_worker(worker) do
    GenServer.call(__MODULE__, {:find_worker, worker})
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:add_worker, worker_pid, worker_name}, _from, state) do
    state = Map.put(state, worker_name, worker_pid)
    {:reply, :ok, state}
  end

  def handle_call({:find_worker, worker}, _from, state) do
    result = Map.get(state, worker)
    {:reply, result, state}
  end

  def handle_call(:get_workers, _from, state) do
    {:reply, state, state}
  end
end
