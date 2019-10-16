defmodule TmuxTracker.Client do
  defstruct(instance: "", processes: [])

  alias __MODULE__
  alias TmuxTracker.TmuxProcess
  alias WorkerTracker.ProcessHelper

  def create(instance) do
    processes =
      instance
      |> get_processes()
      |> Enum.map(&create_process(instance, &1))

    %Client{instance: instance, processes: processes}
  end

  defp get_processes(instance) do
    instance
    |> WorkerTracker.execute_command("ps -xao pid,user,cmd,etimes | grep tmux | grep -v grep")
    |> ProcessHelper.create_list_from_string()
  end

  defdelegate create_process(instance, process_string), to: TmuxProcess, as: :create
end
