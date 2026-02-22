
# Pokeql

Pokeql is a backend Elixir/Phoenix application that provides a fast API for accessing Pokémon data. It acts as a caching proxy for the public [PokeAPI](https://pokeapi.co/), fetching, storing, and serving Pokémon information efficiently to clients.

---

## Features

- **Fast Pokémon API**: Exposes a local API for Pokémon data, reducing repeated calls to the external PokeAPI.
- **Caching**: Uses an in-memory ETS cache for quick data retrieval.
- **Phoenix Web Server**: Built on the Phoenix framework for scalability and maintainability.
- **Internationalization**: Error messages and responses are translatable using Gettext.
- **Telemetry**: Built-in monitoring and metrics.

---

## How It Works

1. **Startup**: The application starts the Phoenix server, Ecto repo, telemetry, and the cache queue.
2. **Cache Initialization**: On boot, the cache queue fetches all Pokémon from the PokeAPI and stores them in ETS.
3. **API Usage**: Clients query the API for Pokémon data, which is served from the local cache for speed.
4. **Error Handling**: Errors are handled and translated using Gettext.

---

## Getting Started

### Prerequisites
- Elixir & Erlang installed ([Install guide](https://elixir-lang.org/install.html))
- PostgreSQL running (for Ecto repo)

### Setup
1. **Install dependencies:**
  ```sh
  mix deps.get
  ```
2. **Create and migrate your database:**
  ```sh
  mix ecto.setup
  ```
3. **Start the Phoenix server:**
  ```sh
  mix phx.server
  ```
4. Visit [`localhost:4000`](http://localhost:4000) in your browser.

---

## API

The API is exposed under `/api`. Example endpoints and usage can be found in the codebase and will typically return cached Pokémon data.

---

## Project Structure

- `lib/pokeql/poke_api.ex`: Fetches data from PokeAPI
- `lib/pokeql/cache.ex`: Manages ETS cache
- `lib/pokeql/cache_queue.ex`: Handles cache population
- `lib/pokeql_web/endpoint.ex`: Phoenix endpoint
- `lib/pokeql_web/router.ex`: API routing

---

## Learn More

- [Phoenix Framework](https://www.phoenixframework.org/)
- [Elixir Lang](https://elixir-lang.org/)
- [PokeAPI](https://pokeapi.co/)

---

## License

MIT
