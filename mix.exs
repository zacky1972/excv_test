defmodule ExcvTest.MixProject do
  use Mix.Project

  def project do
    [
      app: :excv_test,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:elixir_make] ++ Mix.compilers(),
      make_clean: ["clean"]
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
      {:elixir_make, "~> 0.4", runtime: false},
      {:flow, "~> 1.0"},
      {:benchfella, "~> 0.3.0"},
      {:pelemay_fp, "~> 0.1"}
    ]
  end
end
