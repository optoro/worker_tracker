defmodule TmuxTracker.TmuxProcess do
  defstruct owner: "", pid: "", command: "", instance: "", elaspsed_time: 0

  def create(instance, process_string) do
    client = %__MODULE__{instance: instance}

    ~r/(?<pid>\d+)\s(?<user>.*?)\s+(?<command>.*?)\s+(?<elaspsed_time>\d+$)/
    |> Regex.named_captures(process_string)
    |> Map.to_list()
    |> Enum.reduce(client, &build_tmux_client/2)
  end

  defp build_tmux_client({"user", user}, tmux_process) do
    %{tmux_process | owner: user}
  end

  defp build_tmux_client({"pid", pid}, tmux_process) do
    pid = pid |> String.to_integer()
    %{tmux_process | pid: pid}
  end

  defp build_tmux_client({"command", command}, tmux_process) do
    %{tmux_process | command: command}
  end

  defp build_tmux_client({"elaspsed_time", etime}, tmux_process) do
    etime = etime |> String.to_integer()
    %{tmux_process | elaspsed_time: etime}
  end

  defp build_tmux_client({_value, _}, tmux_process) do
    tmux_process
  end
end
