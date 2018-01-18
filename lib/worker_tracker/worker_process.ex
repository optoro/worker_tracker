defmodule WorkerTracker.WorkerProcess do
  defstruct(
    owner: "",
    pid: 0,
    since_time: nil,
    name: "",
    duration: 0
  )

  alias WorkerTracker.WorkerProcess

  def parse_from_process_string(process_string) do
    process_string
    |> clean_process_string
    |> String.split(" ")
    |> Enum.with_index()
    |> Enum.reduce(%WorkerProcess{}, &build_worker_process(&1, &2))
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

  defp clean_process_string(process_string) do
    process_string
    |> String.trim()
    |> String.replace(~r/\s+/, " ")
  end
end
