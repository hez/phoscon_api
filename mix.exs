defmodule PhosconAPI.MixProject do
  use Mix.Project

  @version "0.3.6"

  def project do
    [
      app: :phoscon_api,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dev and test
      {:credo, "~> 1.7.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.2", only: [:dev, :test], runtime: false},
      # Everything else
      {:jason, "~> 1.2"},
      {:tesla, "~> 1.5"},
      {:telemetry, "~> 1.1"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 1.0"},
      {:websockex, "~> 0.4"}
    ]
  end
end
