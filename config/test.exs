use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex_cluster, ExClusterWeb.Endpoint,
  http: [port: System.get_env("PORT") || 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
