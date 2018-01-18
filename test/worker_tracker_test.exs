defmodule WorkerTrackerTest do
  use ExUnit.Case
  doctest WorkerTracker

  test "greets the world" do
    assert WorkerTracker.hello() == :world
  end
end
