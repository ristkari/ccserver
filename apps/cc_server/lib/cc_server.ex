defmodule CCServer do
  require Logger

  # The options below mean:
  #
  # 1. `:binary` - receives data as binaries (instead of lists)
  # 2. `packet: :line` - receives data line by line
  # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
  # 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes
  #

  @doc """
  Starts accepting connections on the given `port`.
  """
  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(
        port,
        [:binary, packet: :line, active: false, reuseaddr: true]
      )

    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    # {:ok, pid} = Task.Supervisor.start_child(CCServer.TaskSupervisor, fn -> serve(client) end)
    {:ok, pid} = Task.Supervisor.start_child(CCServer.TaskSupervisor, fn -> echo_loop(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  def echo_loop(conn) do
    case :gen_tcp.recv(conn, 0) do
      {:ok, packet} ->
        Logger.debug(recv: packet)
        :gen_tcp.send(conn, packet)
        echo_loop(conn)

      {:error, error} ->
        Logger.error(error: error)
    end
  end
end
