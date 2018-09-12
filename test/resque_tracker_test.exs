defmodule ResqueTrackerTest do
  use ExUnit.Case
  doctest ResqueTracker.Client

  alias ResqueTracker.Client
  alias TestHelper.RedisModule

  test "creating a connection" do
    client = Client.create_connection("redis.example.io", RedisModule)
    assert client.conn == true
  end

  test "parsing worker data" do
    client = Client.create_connection("redis.example.io", RedisModule)
    data = Client.get_worker_data(client, "test.worker.io", "TestWorker", "1234")

    {key, value} = data |> hd()

    assert length(data) == 10
    assert key == "resque:worker:test.worker.io:1234:*test_worker*:1"
    assert value == "testing"
  end

  test "collecting failure data" do
    client = Client.create_connection("redis.example.io", RedisModule)
    data = Client.get_failed_workers(client, 3)

    failure = data |> hd()

    assert length(data) == 3
    assert failure == "failed_worker:reason:8"
  end
end
