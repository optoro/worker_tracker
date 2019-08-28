defmodule WorkerTracker.MixProject do
  use Mix.Project

  def project do
    [
      app: :worker_tracker,
      version: "0.2.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :redix],
      mod: {WorkerTracker, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:redix, ">= 0.0.0"},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
    ]
  end

  defp description() do
    "Track system processes across multiple instances over ssh connections"
  end

  defp package() do
    [
      maintainers: ["Jeff Gillis", "Spencer Gilbert", "Anthony Johnston"],
      files: ~w(config lib test .formatter.exs mix.exs README.md),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/..."}
    ]
  end
end
