# Use the official Elixir image
FROM elixir:1.19.5-otp-28

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    inotify-tools \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install Hex and Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Create app directory
WORKDIR /app

# Copy mix files
COPY mix.exs mix.lock ./

# Install mix dependencies
RUN mix deps.get

# Copy source code
COPY . .

# Compile dependencies
RUN mix deps.compile

# Expose port
EXPOSE 4000

# Default command
CMD ["mix", "phx.server"]