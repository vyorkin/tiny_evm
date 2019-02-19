defmodule TinyEVM.MixProject do
  use Mix.Project

  def project do
    [
      app: :tiny_evm,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:poison, "~> 3.1"},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/helpers"]
  defp elixirc_paths(_env), do: ["lib"]
end
