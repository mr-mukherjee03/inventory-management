# Build stage
FROM hexpm/elixir:1.14.5-erlang-25.3.2.8-alpine-3.18.5 AS build

# Install build dependencies
RUN apk add --no-cache build-base git

# Set working directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build environment
ENV MIX_ENV=prod

# Copy mix files
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get --only prod && \
    mix deps.compile

# Copy application files
COPY config config
COPY lib lib
COPY priv priv

# Compile the release
RUN mix compile

# Build the release
RUN mix release

# Runtime stage
FROM alpine:3.18.5 AS app

# Install runtime dependencies
RUN apk add --no-cache libstdc++ openssl ncurses-libs

# Create app user
RUN addgroup -g 1000 app && \
    adduser -u 1000 -G app -s /bin/sh -D app

# Set working directory
WORKDIR /app

# Copy the release from build stage
COPY --from=build --chown=app:app /app/_build/prod/rel/inventory ./

# Switch to app user
USER app

# Expose port
EXPOSE 4000

# Set environment
ENV HOME=/app

# Start the application with migrations
CMD ["sh", "-c", "bin/inventory eval 'Inventory.Release.migrate()' && bin/inventory start"]
