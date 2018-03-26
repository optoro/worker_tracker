defmodule WorkerTracker.InstanceCollection do
  use GenServer

  # Client API
  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def add_instance(instance, pid) do
    GenServer.call(__MODULE__, {:add_instance, pid, instance})
  end

  def find_instance(instance) do
    GenServer.call(__MODULE__, {:find_instance, instance})
  end

  def get_instances() do
    GenServer.call(__MODULE__, :get_instances)
  end

  def process_alive?(instance) do
    GenServer.call(__MODULE__, {:process_alive, instance})
  end

  # Server API
  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:add_instance, instance_pid, instance_name}, _from, instance_map) do
    instance_map = Map.put(instance_map, instance_name, instance_pid)
    {:reply, :ok, instance_map}
  end

  def handle_call({:find_instance, instance}, _from, instance_map) do
    instance_pid = Map.get(instance_map, instance)
    {:reply, instance_pid, instance_map}
  end

  def handle_call(:get_instances, _from, instance_map) do
    {:reply, instance_map, instance_map}
  end

  def handle_call({:process_alive, instance}, _from, instance_map) do
    result = case Map.get(instance_map, instance) do
      nil ->
        false
      pid ->
        Process.alive?(pid)
    end

    {:reply, result, instance_map}
  end
end
