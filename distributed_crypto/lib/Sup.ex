defmodule DistributedCrypto.Sup do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    # We start the HTTP server if the DSN_PORT environment variable is set.
    http =
      case System.get_env("DSN_PORT") do
        nil -> []
        http_port ->
          http_opts = [port: String.to_integer(http_port)]
          [{Plug.Cowboy, scheme: :http, plug: DistributedCrypto.Rest, options: http_opts}]
      end

    # Define the children processes for the supervisor
    children = [
      %{id: DistributedCrypto.Node, start: {DistributedCrypto.Node, :start_link, []}}
    ] ++ http

    # Set the supervision strategy as :one_for_all
    Supervisor.init(children, strategy: :one_for_all)
  end
end
