defmodule Pokeql.PokemonFetcherTest do
  use Pokeql.DataCase

  import Mox
  import Pokeql.PokeAPIFixtures

  alias Pokeql.PokemonFetcher
  alias Pokeql.Cache

  setup :verify_on_exit!

  setup do
    Cache.clear()
    :ok
  end

  defp stub_bulbasaur_api do
    stub(Pokeql.PokeAPIMock, :get_pokemon, fn
      "bulbasaur" -> bulbasaur_pokemon()
      1 -> bulbasaur_pokemon()
    end)

    stub(Pokeql.PokeAPIMock, :get_species, fn "bulbasaur" -> bulbasaur_species() end)

    stub(Pokeql.PokeAPIMock, :get_ability, fn
      "chlorophyll" -> chlorophyll_ability()
      "overgrow" -> overgrow_ability()
    end)

    stub(Pokeql.PokeAPIMock, :get_type, fn
      "grass" -> grass_type()
      "poison" -> poison_type()
    end)

    stub(Pokeql.PokeAPIMock, :get_stat, fn
      "hp" -> hp_stat()
      "attack" -> attack_stat()
      "defense" -> defense_stat()
      "special-attack" -> special_attack_stat()
      "special-defense" -> special_defense_stat()
      "speed" -> speed_stat()
    end)

    stub(Pokeql.PokeAPIMock, :get_move, fn "tackle" -> tackle_move() end)
    stub(Pokeql.PokeAPIMock, :get_version_group, fn "red-blue" -> red_blue_version_group() end)

    stub(Pokeql.PokeAPIMock, :get_game_version, fn
      "red" -> red_game_version()
      "blue" -> blue_game_version()
    end)
  end

  describe "fetch_and_persist/1" do
    test "fetches by name, persists all data, returns fully loaded pokemon" do
      stub_bulbasaur_api()

      assert {:ok, pokemon} = PokemonFetcher.fetch_and_persist("bulbasaur")
      assert pokemon.name == "bulbasaur"
      assert is_integer(pokemon.id)
      assert pokemon.height == 7
      assert pokemon.weight == 69
      assert pokemon.species.name == "bulbasaur"
      assert length(pokemon.abilities) > 0
      assert length(pokemon.types) > 0
      assert length(pokemon.pokemon_stats) > 0
      assert pokemon.sprites != nil
    end

    test "fetches by integer id, persists all data, returns fully loaded pokemon" do
      stub_bulbasaur_api()

      assert {:ok, pokemon} = PokemonFetcher.fetch_and_persist(1)
      assert pokemon.name == "bulbasaur"
    end

    test "is idempotent: calling twice does not duplicate records" do
      stub_bulbasaur_api()

      assert {:ok, _} = PokemonFetcher.fetch_and_persist("bulbasaur")
      assert {:ok, _} = PokemonFetcher.fetch_and_persist("bulbasaur")

      count = Pokeql.Repo.aggregate(Pokeql.Pokemon, :count, :id)
      assert count == 1
    end

    test "populates virtual fields on returned pokemon" do
      stub_bulbasaur_api()

      assert {:ok, pokemon} = PokemonFetcher.fetch_and_persist("bulbasaur")
      assert is_integer(pokemon.total_base_stats)
      assert pokemon.total_base_stats > 0
      assert is_list(pokemon.type_names)
      assert "grass" in pokemon.type_names
    end

    test "returns error when PokeAPI returns not found" do
      stub(Pokeql.PokeAPIMock, :get_pokemon, fn _ -> {:error, {:http_error, 404}} end)

      assert {:error, _} = PokemonFetcher.fetch_and_persist("nonexistent-pokemon")
    end
  end
end
