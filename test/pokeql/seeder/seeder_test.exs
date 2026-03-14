defmodule Pokeql.Seeder.SeederTest do
  use Pokeql.DataCase

  import Mox

  alias Pokeql.PokeAPIFixtures, as: Fixtures

  alias Pokeql.Seeder.Seeder
  alias Pokeql.Repo
  alias Pokeql.Pokemon.{
    Species, Ability, Type, Stat, Move, VersionGroup, GameVersion,
    PokemonAbility, PokemonType, PokemonStat, PokemonMove, Sprite
  }

  setup :verify_on_exit!
  setup do: Mox.set_mox_global()

  defp setup_mocks do
    mock = Pokeql.PokeAPIMock

    stub(mock, :get_generation, fn
      "generation-i" -> Fixtures.generation_i()
    end)

    stub(mock, :get_species, fn
      "bulbasaur" -> Fixtures.bulbasaur_species()
      "ivysaur" -> Fixtures.ivysaur_species()
    end)

    stub(mock, :get_pokemon, fn
      "bulbasaur" -> Fixtures.bulbasaur_pokemon()
      "ivysaur" -> Fixtures.ivysaur_pokemon()
    end)

    stub(mock, :get_ability, fn
      "overgrow" -> Fixtures.overgrow_ability()
      "chlorophyll" -> Fixtures.chlorophyll_ability()
    end)

    stub(mock, :get_type, fn
      "grass" -> Fixtures.grass_type()
      "poison" -> Fixtures.poison_type()
    end)

    stub(mock, :get_stat, fn
      "hp" -> Fixtures.hp_stat()
      "attack" -> Fixtures.attack_stat()
      "defense" -> Fixtures.defense_stat()
      "special-attack" -> Fixtures.special_attack_stat()
      "special-defense" -> Fixtures.special_defense_stat()
      "speed" -> Fixtures.speed_stat()
    end)

    stub(mock, :get_move, fn
      "tackle" -> Fixtures.tackle_move()
    end)

    stub(mock, :get_version_group, fn
      "red-blue" -> Fixtures.red_blue_version_group()
      "yellow" -> Fixtures.yellow_version_group()
    end)

    stub(mock, :get_game_version, fn
      "red" -> Fixtures.red_game_version()
      "blue" -> Fixtures.blue_game_version()
      "yellow" -> Fixtures.yellow_game_version()
    end)
  end

  test "seeds reference tables" do
    setup_mocks()

    Seeder.run()

    assert Repo.aggregate(Species, :count) == 2
    assert Repo.aggregate(Ability, :count) == 2
    assert Repo.aggregate(Type, :count) == 2
    assert Repo.aggregate(Stat, :count) == 6
    assert Repo.aggregate(Move, :count) == 1
    assert Repo.aggregate(VersionGroup, :count) == 2
    assert Repo.aggregate(GameVersion, :count) == 3
  end

  test "seeds pokemon and junction tables" do
    setup_mocks()

    Seeder.run()

    assert Repo.aggregate(Pokeql.Pokemon, :count) == 2
    assert Repo.aggregate(PokemonAbility, :count) == 4
    assert Repo.aggregate(PokemonType, :count) == 4
    assert Repo.aggregate(PokemonStat, :count) == 12
    assert Repo.aggregate(PokemonMove, :count) == 2
    assert Repo.aggregate(Sprite, :count) == 2
  end

  test "is idempotent" do
    setup_mocks()

    Seeder.run()
    Seeder.run()

    assert Repo.aggregate(Species, :count) == 2
  end
end
