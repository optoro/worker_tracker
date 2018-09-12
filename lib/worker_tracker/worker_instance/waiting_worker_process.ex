defmodule WorkerTracker.WorkerInstance.WaitingWorkerProcess do
  defstruct(
    owner: "",
    pid: 0,
    ppid: 0,
    name: ""
  )

  alias __MODULE__
  alias WorkerTracker.ProcessHelper

  @doc ~S"""
  Parses waiting worker information from the given process string

  ## Example

      iex> process_string = "deploy 12345 23456 b c d e f g h i j some_worker_process"
      iex> WorkerTracker.WorkerInstance.WaitingWorkerProcess.parse_worker_process(process_string)
      %WorkerTracker.WorkerInstance.WaitingWorkerProcess{owner: "deploy", pid: 12345, ppid: 23456, name: "some_worker_process"}
  """
  def parse_worker_process(process_string) do
    process_string
    |> ProcessHelper.process_fields(%WaitingWorkerProcess{}, &build_worker_process/2)
  end

  defp build_worker_process({value, 0}, worker_process) do
    %{worker_process | owner: value}
  end

  defp build_worker_process({value, 1}, worker_process) do
    pid =
      value
      |> String.to_integer()

    %{worker_process | pid: pid}
  end

  defp build_worker_process({value, 2}, worker_process) do
    pid =
      value
      |> String.to_integer()

    %{worker_process | ppid: pid}
  end

  defp build_worker_process({value, 12}, worker_process) do
    %{worker_process | name: value}
  end

  defp build_worker_process({_value, _}, worker_process) do
    worker_process
  end
end
