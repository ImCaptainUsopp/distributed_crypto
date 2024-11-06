defmodule DistributedCrypto do

  use Application

  @spec start(any(), any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start(_start_mode, _start_arg) do
    DistributedCrypto.Sup.start_link()
  end
end
