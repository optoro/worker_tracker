defmodule WorkerTracker.WaitingWorkerProcess do
  defstruct(
    owner: "",
    pid: 0,
    name: ""
  )

  alias WorkerTracker.{ProcessHelper, WaitingWorkerProcess}

  @doc ~S"""
  Parses waiting worker information from the given process string

  ## Example

      iex> process_string = "deploy 12345 a b c d e f g h i j k some_worker_process"
      iex> WorkerTracker.WaitingWorkerProcess.parse_worker_process(process_string)
      %WorkerTracker.WaitingWorkerProcess{owner: "deploy", pid: 12345, name: "some_worker_process"}
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

  defp build_worker_process({value, 13}, worker_process) do
    %{worker_process | name: value}
  end

  defp build_worker_process({_value, _}, worker_process) do
    worker_process
  end
end
