defmodule Logflare.Mixfile do
  @moduledoc false
  use Mix.Project
  @version "1.0.0"

  def project do
    [
      app: :logflare,
      version: @version,
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      releases: [
        logflare: [
          version: @version,
          include_executables_for: [:unix],
          applications: [runtime_tools: :permanent, ssl: :permanent]
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Logflare.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :ueberauth_github,
        :edeliver,
        :ueberauth_google,
        :ssl,
        :ueberauth_slack
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib", "priv/tasks"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Phoenix and LogflareWeb
      {:phoenix, "~> 1.5.0", override: true},
      {:phoenix_pubsub, "~> 2.0.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:plug, "~> 1.8"},
      {:plug_cowboy, "~> 2.0"},
      {:phoenix_live_view, "~> 0.13.0"},
      {:phoenix_live_dashboard, "~> 0.1"},
      {:cors_plug, "~> 2.0"},

      # Oauth
      {:ueberauth_google, "~> 0.8"},
      {:ueberauth_github, github: "Logflare/ueberauth_github"},
      {:ueberauth_slack, "~> 0.6"},
      {:oauth2, "~> 2.0.0", override: true},

      # Oauth2 provider
      {:phoenix_oauth2_provider, "~> 0.5.1"},
      {:ex_oauth2_provider, github: "danschultzer/ex_oauth2_provider", override: true},

      # Ecto and DB
      {:postgrex, ">= 0.0.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:distillery, "~> 2.1.0"},
      {:edeliver, ">= 1.7.0"},
      {:deep_merge, "~> 1.0"},
      {:number, "~> 1.0.0"},
      {:timex, "~> 3.1"},
      {:typed_struct, "~> 0.1"},
      {:publicist, "~> 1.1.0"},
      {:lqueue, "~> 1.1"},
      {:cachex, "~> 3.1"},
      {:ex_machina, "~> 2.3"},
      {:iteraptor, "~> 1.10"},
      {:decorator, "~> 1.3"},
      {:atomic_map, "~> 0.9.3"},
      {:libcluster, "~> 3.2"},
      {:map_keys, "~> 0.1.0"},
      {:observer_cli, "~> 1.5"},

      # Parsing
      {:bertex, ">= 0.0.0"},
      {:nimble_parsec, "~> 0.6.0"},

      # Outbound Requests
      {:castore, "~> 0.1.0"},
      {:mint, "~> 1.0"},
      # {:hackney, github: "benoitc/hackney", override: true},
      {:httpoison, "~> 1.4"},
      {:poison, "~> 3.1"},
      {:swoosh, "~> 0.23"},
      {:ex_twilio, "~> 0.8.1"},
      {:tesla, "~> 1.3.0"},

      # Concurrency and pipelines
      {:broadway, "~> 0.5.0"},
      {:flow, "~> 0.14"},

      # Test
      {:placebo, "2.0.0-rc.2"},
      {:mox, "~> 0.5", only: :test},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:faker, "~> 0.12", only: :test},

      # Pagination
      {:scrivener_ecto, "~> 2.2"},
      {:scrivener_list, "~> 2.0"},
      {:scrivener_html, "~> 1.8"},

      # GCP
      {:google_api_cloud_resource_manager, "~> 0.29.0"},
      {:google_api_big_query, "~> 0.38.0"},
      {:goth, "~> 1.2.0"},

      # Ecto
      {:ecto, "~> 3.3", override: true},
      {:ecto_sql, "~> 3.2"},
      {:typed_ecto_schema, "~> 0.1.0"},

      # Telemetry & logging
      {:telemetry, "~> 0.4.0"},
      {:telemetry_poller, "0.4.0"},
      {:telemetry_metrics, "~> 0.4.0"},
      {:logflare_logger_backend, "~> 0.7.6"},
      {:logflare_agent, "~> 0.6.2", only: [:prod]},

      # ETS
      {:ets, "~> 0.8.0"},
      {:ex2ms, "~> 1.0"},
      {:etso, "~> 0.1.1"},

      # Statistics
      {:statistex, "~> 1.0.0"},

      # HTML
      {:floki, "~> 0.26.0"},

      # Rust NIFs
      {:rustler, "~> 0.21.0", override: true},

      # Frontend
      {:phoenix_live_react, "~> 0.2"},

      # Dev
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false},

      # Billing
      {:stripity_stripe, "~> 2.9.0"},
      {:money, "~> 1.7"},

      # Utils
      {:recase, "~> 0.6.0"},
      {:lens, "~> 0.9.0"},

      # Code quality
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:sobelow, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.11", only: :test, runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"]
      # compile: ["compile --warnings-as-errors"]
      # test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
