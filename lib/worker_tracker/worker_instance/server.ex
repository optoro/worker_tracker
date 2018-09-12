defmodule WorkerTracker.WorkerInstance.Server do
  use GenServer

  @refresh_interval :timer.seconds(20)

  alias WorkerTracker.RegistryHelper
  alias WorkerTracker.WorkerInstance.Client

  # Client API
  def start_link(instance) do
    name = name_via_registry(instance)
    GenServer.start_link(__MODULE__, instance, name: name, timeout: :infinity)
  end

  def get_instance(instance) do
    instance
    |> name_via_registry()
    |> GenServer.call(:get_instance, :infinity)
  end

  def refresh_instance(instance) do
    instance
    |> name_via_registry()
    |> GenServer.cast(:refresh_instance)
  end

  def terminate_instance_process(instance, process_id, payload \\ %{}) do
    using_sudo = Application.get_env(:worker_tracker, :use_sudo)

    instance
    |> name_via_registry()
    |> GenServer.call({:terminate_process, process_id, using_sudo}, :infinity)

    %{instance: instance, pid: process_id, timestamp: DateTime.utc_now()}
    |> Map.merge(payload)
    |> notify_terminated()
  end

  # Server  API
  def init(instance) do
    worker_instance = Client.from_instance_name(instance)
    register_with_registry(instance)
    schedule_refresh()
    {:ok, worker_instance}
  end

  def handle_call(:get_instance, _from, worker_instance) do
    {:reply, worker_instance, worker_instance}
  end

  def handle_call({:terminate_process, process_id, use_sudo}, _from, worker_instance) do
    Client.terminate_process(worker_instance, process_id, use_sudo)
    worker_instance = Client.refresh_instance(worker_instance)
    {:reply, worker_instance, worker_instance}
  end

  def handle_cast(:refresh_instance, worker_instance) do
    worker_instance = Client.refresh_instance(worker_instance)
    {:noreply, worker_instance}
  end

  def handle_cast({:terminate_process, process_id, use_sudo}, worker_instance) do
    Client.terminate_process(worker_instance, process_id, use_sudo)
    worker_instance = Client.refresh_instance(worker_instance)
    {:noreply, worker_instance}
  end

  def handle_info(:refresh, worker_instance) do
    worker_instance =
      worker_instance
      |> Client.refresh_instance()

    schedule_refresh()

    {:noreply, worker_instance}
  end

  def handle_info(:timeout, worker_instance) do
    {:noreply, worker_instance}
  end

  defp schedule_refresh() do
    Process.send_after(self(), :refresh, @refresh_interval)
  end

  defp name_via_registry(name) do
    {:via, Registry, {WorkerTracker.WorkerRegistry, name}}
  end

  defp register_with_registry(name) do
    Registry.register(WorkerTracker.CollectionRegistry, "instances", name)
  end

  defp notify_terminated(payload) do
    RegistryHelper.dispatch(WorkerTracker.Notifier, "process_terminated", payload)
  end
end
