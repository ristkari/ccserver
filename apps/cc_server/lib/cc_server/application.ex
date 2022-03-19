defmodule CCServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4040")

    children = [
      {Task.Supervisor, name: CCServer.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> CCServer.accept(port) end}, restart: :permanent)
    ]

    opts = [strategy: :one_for_one, name: CCServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
