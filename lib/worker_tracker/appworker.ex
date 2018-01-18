defmodule WorkerTracker.Appworker do
  def get_process_list(appworker) do
    {:ok, conn} = SSHEx.connect(ip: appworker)
    SSHEx.cmd!(conn, 'ps aux | grep Processing | grep -v grep')
  end
end
