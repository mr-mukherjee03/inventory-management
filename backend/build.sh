set -e

echo "==> Installing Elixir dependencies..."
mix local.hex --force
mix local.rebar --force
mix deps.get --only prod

echo "==> Compiling application..."
MIX_ENV=prod mix compile

echo "==> Running database migrations..."
MIX_ENV=prod mix ecto.migrate

echo "==> Build complete!"
