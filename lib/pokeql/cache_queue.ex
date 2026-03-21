defmodule Pokeql.CacheQueue do
  use GenServer

  alias Pokeql.Cache

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:ok, _} = Cache.create()
    {:ok, state}
  end
end
