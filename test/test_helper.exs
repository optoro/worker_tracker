ExUnit.start()

defmodule TestHelper.RedisModule do
  def start_link(_instance, _port) do
    {:ok, true}
  end

  def command(_conn, ["KEYS", namespace]) do
    key = fix_key(namespace)

    data =
      1..10
      |> Enum.map(&"#{key}:#{&1}")

    {:ok, data}
  end

  def command(_conn, ["GET", _key]) do
    {:ok, "testing"}
  end

  def command(_conn, ["LLEN", _key]) do
    {:ok, 10}
  end

  def command(_conn, ["LRANGE", "resque:failed", index, "-1"]) do
    count = 10 - String.to_integer(index)

    data =
      1..10
      |> Enum.map(&"failed_worker:reason:#{&1}")
      |> Enum.reverse()
      |> Enum.take(count)

    {:ok, data}
  end

  defp fix_key(namespace) do
    namespace
    |> String.split(":")
    |> Enum.slice(0..-1)
    |> Enum.join(":")
  end
end
