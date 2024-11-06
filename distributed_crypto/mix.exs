defmodule DistributedCrypto.MixProject do
  use Mix.Project

  def project do
    [
      app: :distributed_crypto,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp deps do
    [
      {:syn, "~> 3.3.0"},
      {:plug_cowboy, "~> 2.7"},
      {:jason, "~> 1.4"},
      {:local_cluster, "~> 2.0",only: [:test]}
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {DistributedCrypto.App, []}
    ]
  end
end
