defmodule WorkerTracker.ProcessHelper do

  @moduledoc """
  A module to help with processing process strings
  """

  @doc ~S"""
  This function populates the given `accumulator` with the contents of the `process_string` based on the provided
  callback `function`.

  ## Example

      iex> "1 2 3" |> WorkerTracker.ProcessHelper.process_fields(%{}, fn({value, index}, acc) -> Map.put(acc,value,index) end)
      %{"1" => 0, "2" => 1, "3" => 2}
      iex> "1 2 3" |> WorkerTracker.ProcessHelper.process_fields([], fn({value, _index}, acc) -> [value | acc] end)
      ["3", "2", "1"]
  """
  def process_fields(process_string, accumulator, function) do
    process_string
    |> process_fields_with_index()
    |> Enum.reduce(accumulator, &function.(&1, &2))
  end

  @doc ~S"""
  Splits a space-delimited string and returns a list with the index

  ## Example

      iex> "deploy 1123 10" |> WorkerTracker.ProcessHelper.process_fields_with_index()
      [{"deploy", 0}, {"1123", 1}, {"10", 2}]
  """
  def process_fields_with_index(process_string) do
    process_string
    |> clean_process_string()
    |> String.split(" ")
    |> Enum.with_index()
  end

  @doc ~S"""
  A function to find the duration in seconds between utc_now and
  the passed in seconds argument.
  """
  def duration_from_epoch_seconds(seconds) do
    {:ok, datetime} = seconds |> DateTime.from_unix()
    DateTime.diff(DateTime.utc_now(), datetime)
  end

  defp clean_process_string(process_string) do
    process_string
    |> String.trim()
    |> String.replace(~r/\s+/, " ")
  end
end
