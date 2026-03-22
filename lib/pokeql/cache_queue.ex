defmodule Pokeql.CacheQueue do
  @moduledoc "GenServer that initialises the ETS cache table and pre-warms static reference data on startup."

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

    if Application.get_env(:pokeql, :cache_prewarm_on_start, true) do
      send(self(), :prewarm)
    end

    {:ok, state}
  end

  def handle_info(:prewarm, state) do
    Task.start(fn ->
      try do
        PokemonContext.list_types() |> Enum.each(&Cache.put_type/1)
        PokemonContext.list_stats() |> Enum.each(&Cache.put_stat/1)
      rescue
        _ -> :ok
      catch
        :exit, _ -> :ok
      end
    end)

    {:noreply, state}
  end
end
