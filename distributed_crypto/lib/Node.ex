defmodule DistributedCrypto.Node do
  require Logger
  use GenServer

  ### Interface

  @spec increment() :: :ok
  def increment(), do: GenServer.cast(__MODULE__, :increment)

  @spec decrement() :: :ok
  def decrement(), do: GenServer.cast(__MODULE__, :decrement)

  @spec get_value() :: {:ok, integer()}
  def get_value(), do: GenServer.call(__MODULE__, :get_value)

  @spec get_value(node()) :: {:ok, integer()}
  def get_value(node), do: GenServer.call({__MODULE__,node}, :get_value)

  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link(), do: GenServer.start_link(__MODULE__, {}, name: __MODULE__)

  ### Callbacks

  defmodule State do
    @enforce_keys [:value]
    defstruct value: 0

    @typedoc """
    This is the state of our node, containing a shared value.
    """
    @type t() :: %__MODULE__{
            value: integer()
          }
  end

  @impl GenServer
  def init( ) do
    Logger.info("NodeCrypto started")
  end

  @impl GenServer
  def handle_call(:get_value, _from, state = %State{value: value}) do
    {:reply, {:ok, value}, state}
  end

  @impl GenServer
  def handle_cast(:increment, state) do
    self = self()
    new_value = state.value + 1
    Logger.debug("Incrementing value to #{new_value}")

    # Propagate the increment to other nodes
    members = for {pid, _} <- :syn.members(:distributed_crypto, :node_crypto), pid != self, do: pid
    members |> Enum.each(fn pid -> GenServer.cast(pid, :increment) end)

    {:noreply, %State{state | value: new_value}}
  end

  @impl GenServer
  def handle_cast(:decrement, state) do
    self = self()
    new_value = state.value - 1
    Logger.debug("Decrementing value to #{new_value}")

    # Propagate the decrement to other nodes
    members = for {pid, _} <- :syn.members(:distributed_crypto, :node_crypto), pid != self, do: pid
    members |> Enum.each(fn pid -> GenServer.cast(pid, :decrement) end)

    {:noreply, %State{state | value: new_value}}
  end
end
