defmodule InventoryWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :inventory

  
  # Set :encryption_salt to encrypt.
  @session_options [
    store: :cookie,
    key: "_inventory_key",
    signing_salt: "inventory_signing_salt",
    same_site: "Lax"
  ]

  plug Plug.Static,
    at: "/",
    from: :inventory,
    gzip: false,
    only: InventoryWeb.static_paths()

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  # CORS configuration
  plug CORSPlug,
    origin: &InventoryWeb.Endpoint.cors_origin/0,
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    headers: ["Authorization", "Content-Type", "Accept", "Origin"]

  def cors_origin do
    if Mix.env() == :prod do
      # Allow all origins in production
      ["*"]
    else
      # Restrict to localhost in development
      ["http://localhost:5173", "http://localhost:3000"]
    end
  end

  plug InventoryWeb.Router
end
