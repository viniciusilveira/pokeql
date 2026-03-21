defmodule Pokeql.CacheTest do
  use ExUnit.Case, async: false

  alias Pokeql.Cache
  alias Pokeql.Pokemon

  setup do
    Cache.clear()
    :ok
  end

  defp build_pokemon(attrs \\ []) do
    defaults = %Pokemon{
      id: 1,
      name: "bulbasaur",
      height: 7,
      weight: 69,
      order: 1,
      is_default: true
    }

    struct(defaults, attrs)
  end

  describe "put_pokemon/1 and get_pokemon/1" do
    test "stores and retrieves a pokemon by integer id" do
      pokemon = build_pokemon(id: 42, name: "pikachu")

      :ok = Cache.put_pokemon(pokemon)

      assert {:ok, retrieved} = Cache.get_pokemon(42)
      assert retrieved.id == 42
      assert retrieved.name == "pikachu"
    end

    test "returns :miss when pokemon id not in cache" do
      assert :miss = Cache.get_pokemon(999)
    end

    test "overwrites existing entry on second put" do
      pokemon = build_pokemon(id: 1, name: "bulbasaur")
      updated = build_pokemon(id: 1, name: "bulbasaur", height: 99)

      Cache.put_pokemon(pokemon)
      Cache.put_pokemon(updated)

      assert {:ok, retrieved} = Cache.get_pokemon(1)
      assert retrieved.height == 99
    end
  end

  describe "get_pokemon_by_name/1" do
    test "retrieves a pokemon by name" do
      pokemon = build_pokemon(id: 1, name: "bulbasaur")

      Cache.put_pokemon(pokemon)

      assert {:ok, retrieved} = Cache.get_pokemon_by_name("bulbasaur")
      assert retrieved.id == 1
      assert retrieved.name == "bulbasaur"
    end

    test "returns :miss when pokemon name not in cache" do
      assert :miss = Cache.get_pokemon_by_name("nonexistent")
    end

    test "both id and name lookups return the same struct" do
      pokemon = build_pokemon(id: 5, name: "charmeleon")

      Cache.put_pokemon(pokemon)

      {:ok, by_id} = Cache.get_pokemon(5)
      {:ok, by_name} = Cache.get_pokemon_by_name("charmeleon")

      assert by_id == by_name
    end
  end

  describe "delete_pokemon/1" do
    test "removes both id and name entries" do
      pokemon = build_pokemon(id: 3, name: "venusaur")
      Cache.put_pokemon(pokemon)

      Cache.delete_pokemon(pokemon)

      assert :miss = Cache.get_pokemon(3)
      assert :miss = Cache.get_pokemon_by_name("venusaur")
    end

    test "is a no-op when pokemon is not in cache" do
      pokemon = build_pokemon(id: 999, name: "missing-no")
      assert :ok = Cache.delete_pokemon(pokemon)
    end
  end

  describe "count/0" do
    test "returns 0 on empty cache" do
      assert Cache.count() == 0
    end

    test "returns 2 after adding one pokemon (two ETS entries per pokemon)" do
      pokemon = build_pokemon(id: 7, name: "squirtle")
      Cache.put_pokemon(pokemon)

      assert Cache.count() == 2
    end

    test "increases by 2 for each added pokemon" do
      Cache.put_pokemon(build_pokemon(id: 1, name: "bulbasaur"))
      Cache.put_pokemon(build_pokemon(id: 4, name: "charmander"))

      assert Cache.count() == 4
    end
  end

  describe "clear/0" do
    test "removes all entries from the cache" do
      Cache.put_pokemon(build_pokemon(id: 1, name: "bulbasaur"))
      Cache.put_pokemon(build_pokemon(id: 4, name: "charmander"))

      Cache.clear()

      assert Cache.count() == 0
      assert :miss = Cache.get_pokemon(1)
      assert :miss = Cache.get_pokemon_by_name("bulbasaur")
    end
  end

  describe "get_all/0" do
    test "returns all ETS entries" do
      Cache.put_pokemon(build_pokemon(id: 1, name: "bulbasaur"))

      entries = Cache.get_all()
      assert length(entries) == 2
    end

    test "returns empty list when cache is empty" do
      assert Cache.get_all() == []
    end
  end
end
