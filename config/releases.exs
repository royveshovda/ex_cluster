import Config

service_name = System.fetch_env!("SERVICE_NAME")
secret_key_base = System.fetch_env!("SECRET_KEY_BASE")
port = System.fetch_env!("PORT")
node_name = System.fetch_env!("NODE_NAME") || "ex_cluster"

config :ex_cluster, ExClusterWeb.Endpoint,
  http: [port: port],
  secret_key_base: secret_key_base,
  url: [host: {:system, "APP_HOST"}, port: {:system, "PORT"}]

#config :peerage, via: Peerage.Via.Dns,
#  dns_name: service_name,
#  app_name: "node_name"

config :peerage,
  via: Peerage.Via.List,
  node_list: [:"node1@node1.local", :"node2@node2.local", :"node3@node3.local"],
  log_results: true