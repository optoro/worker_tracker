defmodule WorkerTracker.ParentWorkerProcess do
  defstruct pid: 0,
    child_pid: 0,
    owner: "",
    forked_time: 0

  @moduledoc ~S"""
    A module for parsing parent resque processes from a process string
  """

  alias WorkerTracker.{ParentWorkerProcess, ProcessHelper}

  @doc ~S"""
    Parse Parent Worker Processes from the given `process_string`.

    ## Example:
      iex(1)> "deploy 46465 6.8 1.1 580308 388852 ? S 12:21 2:06 resque-1.25.2: Forked 94996 at 1523970475" |> WorkerTracker.ParentWorkerProcess.parse_worker_process()
      %WorkerTracker.ParentWorkerProcess{
        child_pid: 94996,
        forked_time: 1523970475,
        owner: "deploy",
        pid: 46465
      }
  """
  def parse_worker_process(process_string) do
    process_string
    |> ProcessHelper.process_fields(%ParentWorkerProcess{}, &build_worker_process/2)
  end

  defp build_worker_process({value, 0}, %ParentWorkerProcess{} = worker_process) do
    %{ worker_process | owner: value}
  end

  defp build_worker_process({value, 1}, %ParentWorkerProcess{} = worker_process) do
    value = value |> String.to_integer()
    %{ worker_process | pid: value}
  end

  defp build_worker_process({value, 12}, %ParentWorkerProcess{} = worker_process) do
    value = value |> String.to_integer()
    %{ worker_process | child_pid: value}
  end

  defp build_worker_process({value, 14}, %ParentWorkerProcess{} = worker_process) do
    value = value |> String.to_integer()
    %{ worker_process | forked_time: value}
  end

  defp build_worker_process({_value, _}, %ParentWorkerProcess{} = worker_process) do
    worker_process
  end
end
