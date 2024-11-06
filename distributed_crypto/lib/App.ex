defmodule DistributedCrypto.App do
  use Application

  def start(_start_mode, _start_arg) do
    :ok = :syn.add_node_to_scopes([:distributed_crypto, :behaviour_example])
    DistributedCrypto.Sup.start_link()
  end
end
