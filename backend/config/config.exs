import Config

config :inventory,
  ecto_repos: [Inventory.Repo],
  generators: [timestamp_type: :utc_datetime]

config :inventory, InventoryWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [json: InventoryWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Inventory.PubSub,
  live_view: [signing_salt: "inventory_live_view_salt"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :module, :function]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
