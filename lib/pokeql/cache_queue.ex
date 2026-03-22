defmodule Pokeql.CacheQueue do
  use GenServer

  alias Pokeql.Cache
  alias Pokeql.PokemonContext

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @doc """
  Triggers a pre-warm of static reference data (types and stats) into the cache.
  Returns immediately; the actual loading happens asynchronously.
  """
  def prewarm do
    send(__MODULE__, :prewarm)
    :ok
  end

  def init(state) do
    {:ok, _} = Cache.create()
    send(self(), :prewarm)
    {:ok, state}
  end

  def handle_info(:prewarm, state) do
    Task.start(fn ->
      PokemonContext.list_types()
      |> Enum.each(&Cache.put_type/1)

      PokemonContext.list_stats()
      |> Enum.each(&Cache.put_stat/1)
    end)

    {:noreply, state}
  end
end
