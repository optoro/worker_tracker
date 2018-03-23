defmodule WorkerTracker.InstanceConnection do
  # ruby      82547  deploy   19u  IPv4  32856       TCP appworker-131.optiturn.com:43798->mongo-replmem-010-optiturn-com.inst.optiturn.iad3.cns.us-east.optoro.io:27017 (ESTABLISHED)
  # command: sudo lsof -i | grep -i established

  defstruct(
    program: "",
    pid: nil,
    owner: "",
    protocol: "",
    local_socket: "",
    remote_socket: "",
    state: ""
  )

  alias WorkerTracker.InstanceConnection
  alias WorkerTracker.ProcessHelper

  @doc ~S"""
    Parse connection information from lsof output string

    ## Example

      iex> WorkerTracker.InstanceConnection.from_connection_string("ruby      82547  deploy   19u  IPv4  32856       TCP appworker-131.optiturn.com:43798->mongo-replmem-010-optiturn-com.inst.optiturn.iad3.cns.us-east.optoro.io:27017 (ESTABLISHED)")
      %WorkerTracker.InstanceConnection{
        local_socket: "appworker-131.optiturn.com:43798",
        owner: "deploy",
        pid: 82547,
          program: "ruby",
        protocol: "TCP",
        remote_socket: "mongo-replmem-010-optiturn-com.inst.optiturn.iad3.cns.us-east.optoro.io:27017",
        state: "ESTABLISHED"
        }
  """
  def from_connection_string(connection_string) do
    connection_string
    |> ProcessHelper.process_fields_with_index()
    |> Enum.reduce(%InstanceConnection{}, &parse_connection_string/2)
  end

  defp parse_connection_string({value, 0}, instance_connection) do
    %{ instance_connection | program: value }
  end

  defp parse_connection_string({value, 1}, instance_connection) do
    pid = value |> String.to_integer()
    %{instance_connection | pid: pid}
  end

  defp parse_connection_string({value, 2}, instance_connection) do
    %{instance_connection | owner: value}
  end

  defp parse_connection_string({value, 6}, instance_connection) do
    %{instance_connection | protocol: value}
  end

  defp parse_connection_string({value, 7}, instance_connection) do
    [local_socket, remote_socket] = value |> String.split("->")
    %{instance_connection | local_socket: local_socket, remote_socket: remote_socket}
  end

  defp parse_connection_string({value, 8}, instance_connection) do
    state =
      value
      |> String.replace(~r/\(|\)/, "")

    %{instance_connection | state: state}
  end

  defp parse_connection_string({_value, _}, instance_connection) do
    instance_connection
  end

end
