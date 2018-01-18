defmodule WorkerTracker do
  alias WorkerTracker.WorkerProcess

  def parse_process_string(process_string) do
    process_string
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&WorkerProcess.parse_from_process_string/1)
  end
end
