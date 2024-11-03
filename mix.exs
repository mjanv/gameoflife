defmodule Gameoflife.MixProject do
  use Mix.Project

  def project do
    [
      app: :gameoflife,
      version: "1.1.0",
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: [warnings_as_errors: true],
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      preferred_envs: [quality: :dev, test: :test],
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Gameoflife.Application, []},
      extra_applications: [:os_mon, :logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Web
      {:bandit, "~> 1.5"},
      {:phoenix, "~> 1.7"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.0.0-rc.1", override: true},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:phoenix_live_reload, "~> 1.5", only: :dev},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      # Backend
      {:dns_cluster, "~> 0.1.1"},
      {:libcluster, "~> 3.3"},
      {:horde, "~> 0.9"},
      {:jason, "~> 1.2"},
      {:number, "~> 1.0"},
      # Monitoring
      {:telemetry, "~> 1.3"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.1"},
      # Developement tools
      {:floki, ">= 0.30.0", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:benchee, "~> 1.3", only: [:dev, :test]},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:doctor, "~> 0.21.0"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind gameoflife", "esbuild gameoflife"],
      "assets.deploy": [
        "tailwind gameoflife --minify",
        "esbuild gameoflife --minify",
        "phx.digest"
      ],
      quality: ["format --check-formatted", "credo --strict", "dialyzer"],
      test: ["test"],
      start: ["phx.server"],
      docs: ["doctor", "docs"],
      commit: [
        fn _ -> System.cmd("git", ["add", "."]) end,
        fn _ -> System.cmd("git", ["commit", "-m", "wip"]) end
      ]
    ]
  end
end
