defmodule Pokeql.CacheTest do
  use ExUnit.Case, async: false

  alias Pokeql.Cache
  alias Pokeql.Pokemon
  alias Pokeql.Pokemon.Ability
  alias Pokeql.Pokemon.Move
  alias Pokeql.Pokemon.Type
  alias Pokeql.Pokemon.Stat
  alias Pokeql.Pokemon.Species

  setup do
    Cache.clear()
    :ok
  end

  defp build_pokemon(attrs) do
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

  describe "put_ability/1 and get_ability/1" do
    test "stores and retrieves an ability by name" do
      ability = %Ability{
        id: 1,
        name: "overgrow",
        generation_name: "generation-iii",
        is_main_series: true,
        short_effect: "Strengthens grass moves."
      }

      :ok = Cache.put_ability(ability)

      assert {:ok, retrieved} = Cache.get_ability("overgrow")
      assert retrieved.id == 1
      assert retrieved.name == "overgrow"
    end

    test "returns :miss when ability not in cache" do
      assert :miss = Cache.get_ability("chlorophyll")
    end

    test "overwrites existing entry on second put" do
      ability = %Ability{
        id: 1,
        name: "overgrow",
        generation_name: "generation-iii",
        is_main_series: true,
        short_effect: "old"
      }

      updated = %Ability{
        id: 1,
        name: "overgrow",
        generation_name: "generation-iii",
        is_main_series: true,
        short_effect: "new"
      }

      Cache.put_ability(ability)
      Cache.put_ability(updated)

      assert {:ok, retrieved} = Cache.get_ability("overgrow")
      assert retrieved.short_effect == "new"
    end
  end

  describe "put_move/1 and get_move/1" do
    test "stores and retrieves a move by name" do
      move = %Move{
        id: 1,
        name: "tackle",
        generation_name: "generation-i",
        type_name: "normal",
        damage_class_name: "physical",
        power: 40,
        pp: 35,
        accuracy: 100,
        priority: 0,
        short_effect: "Normal damage."
      }

      :ok = Cache.put_move(move)

      assert {:ok, retrieved} = Cache.get_move("tackle")
      assert retrieved.id == 1
      assert retrieved.name == "tackle"
    end

    test "returns :miss when move not in cache" do
      assert :miss = Cache.get_move("ember")
    end
  end

  describe "put_type/1 and get_type/1" do
    test "stores and retrieves a type by name" do
      type = %Type{
        id: 1,
        name: "fire",
        generation_name: "generation-i",
        damage_class_name: "special"
      }

      :ok = Cache.put_type(type)

      assert {:ok, retrieved} = Cache.get_type("fire")
      assert retrieved.id == 1
      assert retrieved.name == "fire"
    end

    test "returns :miss when type not in cache" do
      assert :miss = Cache.get_type("water")
    end
  end

  describe "put_stat/1 and get_stat/1" do
    test "stores and retrieves a stat by name" do
      stat = %Stat{id: 1, name: "hp", game_index: 1, is_battle_only: false}

      :ok = Cache.put_stat(stat)

      assert {:ok, retrieved} = Cache.get_stat("hp")
      assert retrieved.id == 1
      assert retrieved.name == "hp"
    end

    test "returns :miss when stat not in cache" do
      assert :miss = Cache.get_stat("attack")
    end
  end

  describe "put_species/1 and get_species/1" do
    test "stores and retrieves a species by name" do
      species = %Species{
        id: 1,
        name: "bulbasaur",
        generation_name: "generation-i",
        color_name: "green",
        shape_name: "quadruped",
        growth_rate_name: "medium-slow",
        gender_rate: 1,
        capture_rate: 45,
        base_happiness: 50,
        is_baby: false,
        hatch_counter: 20,
        has_gender_differences: false,
        is_legendary: false,
        is_mythical: false
      }

      :ok = Cache.put_species(species)

      assert {:ok, retrieved} = Cache.get_species("bulbasaur")
      assert retrieved.id == 1
      assert retrieved.name == "bulbasaur"
    end

    test "returns :miss when species not in cache" do
      assert :miss = Cache.get_species("ivysaur")
    end
  end

  describe "ETS table name" do
    test "the cache table is named :pokeql_cache" do
      assert :ets.info(:pokeql_cache) != :undefined
    end

    test "the old :pokemons table does not exist" do
      assert :ets.info(:pokemons) == :undefined
    end
  end
end
