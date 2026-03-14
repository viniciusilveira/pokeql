defmodule Pokeql.CacheQueue do
  use GenServer

  require Logger

  alias Pokeql.Cache

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    case Cache.create() do
      {:ok, _list} ->
        {:ok, state}

      {:error, _error} ->
        raise "Does not start cache"
    end
  end

  def handle_cast({:insert_pokemon, pokemon}, _state) do
    case Cache.insert_pokemon(pokemon) do
      true ->
        {:noreply, true}

      {:error, %HTTPoison.Error{reason: :nxdomain}} ->
        Logger.error("Error to get deatils for #{pokemon["name"]}", %{reason: :nxdomain})
        GenServer.cast(__MODULE__, {:insert_pokemon, pokemon})
        {:noreply, :nxdomain}

      _ ->
        GenServer.cast(__MODULE__, {:insert_pokemon, pokemon})
        Logger.error("Error to get deatils for #{pokemon["name"]}", %{reason: :generic_error})
        {:noreply, false}
    end
  end

  def insert_pokemon(pokemon) do
    GenServer.cast(__MODULE__, {:insert_pokemon, pokemon})
  end
end
