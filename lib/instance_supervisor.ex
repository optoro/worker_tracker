defmodule InstanceSupervisor do
  def init() do
    children = [
      {DynamicSupervisor, name: __MODULE__, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
