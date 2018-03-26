defmodule WorkerTracker.ProcessHelper do
  @moduledoc """
  A module to help with processing process strings
  """

  @doc ~S"""
  This function populates the given `accumulator` with the contents of the `process_string` based on the provided callback `function`.

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
    |> clean_command_string()
    |> String.split(" ")
    |> Enum.with_index()
  end

  @doc ~S"""
  A function to find the duration in seconds between utc_now and the passed in seconds argument.
  """
  def duration_from_epoch_seconds(seconds) do
    {:ok, datetime} = seconds |> DateTime.from_unix()
    DateTime.diff(DateTime.utc_now(), datetime)
  end

  @doc ~S"""
  A function that creates a list from the given `process_string`

  ## Example

      iex(1)> WorkerTracker.ProcessHelper.create_list_from_string("a\nb\nc\n")
      ["a", "b", "c"]
  """
  def create_list_from_string(process_string) do
    process_string
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
  end

  @doc ~S"""
  This function filters the `process_list` for the given `filter_string` and returns the result of applying the `filter_function`.

  ## Example

      iex(1)> WorkerTracker.ProcessHelper.filter_and_transform_process_list(["a b", "c d"], "a", &String.split(&1))
      [["a", "b"]]
  """
  def filter_and_transform_process_list(process_list, filter_string, parser_function) do
    process_list
    |> Enum.filter(&String.contains?(&1, filter_string))
    |> Enum.map(&parser_function.(&1))
  end

  defp clean_command_string(command_string) do
    command_string
    |> String.trim()
    |> String.replace(~r/\s+/, " ")
  end
end
