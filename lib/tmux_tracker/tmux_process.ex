defmodule TmuxTracker.TmuxProcess do
  defstruct owner: "", pid: "", name: "", instance: ""

  alias __MODULE__
  alias WorkerTracker.ProcessHelper

  def create(instance, process_string) do
    client = %TmuxProcess{instance: instance}

    process_string
    |> ProcessHelper.process_fields(client, &build_tmux_client/2)
  end

  defp build_tmux_client({value, 0}, tmux_process) do
    %{tmux_process | owner: value}
  end

  defp build_tmux_client({value, 1}, tmux_process) do
    pid = value |> String.to_integer()
    %{tmux_process | pid: pid}
  end

  defp build_tmux_client({value, 10}, tmux_process) do
    %{tmux_process | name: value}
  end

  defp build_tmux_client({_value, _}, tmux_process) do
    tmux_process
  end
end
