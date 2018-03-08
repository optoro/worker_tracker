defmodule WorkerTracker.ActiveWorkerProcess do
  defstruct(
    owner: "",
    pid: 0,
    since_time: nil,
    name: "",
    duration: 0
  )

  alias WorkerTracker.{ActiveWorkerProcess, ProcessHelper}

  @doc ~S"""
  Parses active worker information from the given process string

  ## Example

      iex> process_string = "deploy 12345 a b c d e f g h i j k l 1516831492 [some_worker_process]"
      iex> worker_process = WorkerTracker.ActiveWorkerProcess.parse_worker_process(process_string)
      iex> worker_process.name == "some_worker_process"
      true
  """
  def parse_worker_process(process_string) do
    process_string
    |> ProcessHelper.process_fields(%ActiveWorkerProcess{}, &build_worker_process/2)
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

  defp build_worker_process({value, 14}, worker_process) do
    {:ok, datetime} =
      value
      |> String.to_integer()
      |> DateTime.from_unix()

    duration = DateTime.diff(DateTime.utc_now(), datetime)
    %{worker_process | since_time: datetime, duration: duration}
  end

  defp build_worker_process({value, 15}, worker_process) do
    name =
      value
      |> String.replace(~r/\[|\]/, "")

    %{worker_process | name: name}
  end

  defp build_worker_process({_value, _}, worker_process) do
    worker_process
  end
end
