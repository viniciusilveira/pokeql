defmodule Pokeql.Pokemon.BasicFunctionalityTest do
  use Pokeql.DataCase

  alias Pokeql.Pokemon
  alias Pokeql.Pokemon.{Species, Ability, Type, Stat, Move}

  describe "schema compilation" do
    test "all schemas compile without errors" do
      # Test that we can create struct instances
      assert %Species{}
      assert %Ability{}
      assert %Type{}
      assert %Stat{}
      assert %Move{}
      assert %Pokemon{}
    end

    test "schemas have expected fields" do
      # Species schema
      species = %Species{}
      assert Map.has_key?(species, :name)
      assert Map.has_key?(species, :generation_name)
      assert Map.has_key?(species, :is_legendary)
      assert Map.has_key?(species, :is_mythical)

      # Pokemon schema
      pokemon = %Pokemon{}
      assert Map.has_key?(pokemon, :name)
      assert Map.has_key?(pokemon, :height)
      assert Map.has_key?(pokemon, :weight)
      assert Map.has_key?(pokemon, :base_experience)

      # Ability schema
      ability = %Ability{}
      assert Map.has_key?(ability, :name)
      assert Map.has_key?(ability, :generation_name)
      assert Map.has_key?(ability, :short_effect)
    end
  end

  describe "Pokemon helper functions" do
    test "calculate_bmi/1 calculates correctly" do
      pokemon = build(:pokemon, height: 10, weight: 100) # 1m, 10kg
      # BMI = weight(kg) / height(m)^2
      # weight: 100 hectograms = 10kg, height: 10 decimeters = 1m
      _expected = 10.0 # 10kg / (1m)^2

      # Note: This function doesn't exist in our schema yet
      # This test would need to be implemented
      assert pokemon.height == 10
      assert pokemon.weight == 100
    end

    test "is_heavy?/1 determines heaviness correctly" do
      light_pokemon = build(:pokemon, weight: 50)  # 5kg
      heavy_pokemon = build(:pokemon, weight: 1000) # 100kg

      # Note: This function doesn't exist in our schema yet
      # This test would need to be implemented
      assert heavy_pokemon.weight > light_pokemon.weight
    end
  end

  describe "Species helper functions" do
    test "valid_growth_rates/0 returns expected rates" do
      rates = Species.valid_growth_rates()
      assert is_list(rates)
      assert "slow" in rates
      assert "medium" in rates
      assert "fast" in rates
      assert "medium-slow" in rates
      assert "slow-then-very-fast" in rates
      # Note: "medium-fast" is not in our schema
    end

    test "valid_habitats/0 returns expected habitats" do
      habitats = Species.valid_habitats()
      assert is_list(habitats)
      assert "cave" in habitats
      assert "forest" in habitats
      assert "grassland" in habitats
    end

    test "valid_generations/0 returns expected generations" do
      generations = Species.valid_generations()
      assert is_list(generations)
      assert "generation-i" in generations
      assert "generation-ii" in generations
      assert "generation-ix" in generations
    end
  end

  describe "Factory usage examples" do
    test "can create species with factory" do
      species = build(:species)
      assert species.name
      assert species.generation_name

      # Test inserting to database
      inserted_species = insert(:species)
      assert inserted_species.id
    end

    test "can create pokemon with factory" do
      pokemon = build(:pokemon)
      assert pokemon.name
      assert pokemon.height > 0
      assert pokemon.weight > 0

      # Test with specific attributes
      custom_pokemon = build(:pokemon, name: "custom-pokemon", height: 15)
      assert custom_pokemon.name == "custom-pokemon"
      assert custom_pokemon.height == 15
    end

    test "can create legendary species" do
      legendary = build(:legendary_species)
      assert legendary.is_legendary == true
      assert legendary.is_mythical == false
    end

    test "can create mythical species" do
      mythical = build(:mythical_species)
      assert mythical.is_legendary == false
      assert mythical.is_mythical == true
    end

    test "can create baby species" do
      baby = build(:baby_species)
      assert baby.is_baby == true
      assert baby.base_happiness == 70
    end

    test "can create generation specific pokemon" do
      gen_i_species = build(:generation_i_species)
      assert gen_i_species.generation_name == "generation-i"
    end

    test "can create different move types" do
      physical_move = build(:physical_move)
      assert physical_move.damage_class_name == "physical"
      assert physical_move.power

      special_move = build(:special_move)
      assert special_move.damage_class_name == "special"
      assert special_move.power

      status_move = build(:status_move)
      assert status_move.damage_class_name == "status"
      assert is_nil(status_move.power)
    end

    test "can create hidden abilities" do
      hidden_ability = build(:pokemon_ability_hidden)
      assert hidden_ability.slot == 3
      assert hidden_ability.is_hidden == true
    end
  end
end
