defmodule WorkerTracker.WorkerInstance.ResquePoolMasterProcess do
  defstruct(
    owner: "",
    pid: 0,
    ppid: 0,
    name: "",
    managed_processes: []
  )

  alias __MODULE__
  alias WorkerTracker.ProcessHelper

  @doc ~S"""

  Parses resque-pool-master process information from the given process string

  ## Example

      iex> process_string = deploy   12345 23456 23456 23456 11 03:20 ?        00:36:04 resque-pool-master[90c000d68d5ac6f9b8de937161187f50c5b60722]: managing [26033, 26042]
      iex> WorkerTracker.WorkerInstance.ResquePoolMasterProcess.parse_master_process(process_string)
      %WorkerTracker.WorkerInstance.ResquePoolMasterProcess{owner: "deploy", pid: 12345, ppid: 23456, name: resque-pool-master[90c000d68d5ac6f9b8de937161187f50c5b60722], managed_processes: [26033, 26042]}
  """
  def parse_master_process(process_string) do
    process_string
    |> ProcessHelper.process_fields(%ResquePoolMasterProcess{}, &build_master_process/2)
  end

  defp build_master_process({value, 0}, master_process) do
    %{master_process | owner: value}
  end

  defp build_master_process({value, 1}, master_process) do
    pid =
      value
      |> String.to_integer()

    %{master_process | pid: pid}
  end

  defp build_master_process({value, 2}, master_process) do
    ppid =
      value
      |> String.to_integer()

    %{master_process | ppid: ppid}
  end

  defp build_master_process({value, 9}, master_process) do
    name =
      value
      |> String.replace(~r/:/, "")

    %{master_process | name: name}
  end

  defp build_master_process({value, index}, master_process) do
    if index > 10 do
      managed_pid =
        value
        |> String.replace(~r/[^\d]/, "")
        |> String.to_integer()

      %{master_process | managed_processes: master_process.managed_processes ++ [managed_pid]}
    else
      master_process
    end
  end
end
