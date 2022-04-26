defmodule Pokeql.CacheQueue do
  use GenServer

  alias Pokeql.Cache

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state), do: {:ok, state}

  def handle_cast({:insert_pokemon, pokemon}, state) do
    IO.puts("insert new pokemon => #{pokemon["id"]} - #{pokemon["name"]} --- #{state}\n")

    case Cache.insert_pokemon(pokemon) do
      true -> {:noreply, true}
      _ -> {:noreply, false}
    end
  end

  # GenServer.cast(Pokeql.CacheQueue, {:create_cache, []})
  def handle_cast({:create_cache, _value}, state) do
    Cache.create()
    {:noreply, state}
  end

  def insert_pokemon(pokemon) do
    GenServer.cast(__MODULE__, {:insert_pokemon, pokemon})
  end
end
