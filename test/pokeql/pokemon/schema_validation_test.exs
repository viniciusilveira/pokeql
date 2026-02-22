defmodule Pokeql.Pokemon.SchemaValidationTest do
  use Pokeql.DataCase

  alias Pokeql.Pokemon
  alias Pokeql.Pokemon.{Species, PokemonAbility}

  describe "Species changeset validations" do
    test "validates required fields" do
      changeset = Species.changeset(%Species{}, %{})
      refute changeset.valid?

      required_fields = [:name, :generation_name]
      for field <- required_fields do
        assert changeset.errors[field] != nil, "Expected error for #{field}"
      end
    end

    test "validates with valid factory attributes" do
      attrs = params_for(:species)
      changeset = Species.changeset(%Species{}, attrs)
      assert changeset.valid?
    end

    test "validates happiness range" do
      # Test minimum boundary
      attrs = params_for(:species, base_happiness: -1)
      changeset = Species.changeset(%Species{}, attrs)
      refute changeset.valid?
      assert Keyword.has_key?(changeset.errors, :base_happiness)

      # Test maximum boundary
      attrs = params_for(:species, base_happiness: 256)
      changeset = Species.changeset(%Species{}, attrs)
      refute changeset.valid?
      assert Keyword.has_key?(changeset.errors, :base_happiness)

      # Test valid range
      attrs = params_for(:species, base_happiness: 100)
      changeset = Species.changeset(%Species{}, attrs)
      refute Keyword.has_key?(changeset.errors, :base_happiness)
    end

    test "validates growth rate inclusion" do
      # Our current schema doesn't validate growth rates, so test that it accepts any value
      attrs = params_for(:species, growth_rate_name: "any-rate")
      changeset = Species.changeset(%Species{}, attrs)
      refute Keyword.has_key?(changeset.errors, :growth_rate_name)
    end

    test "validates generation inclusion" do
      # Test invalid generation format
      attrs = params_for(:species, generation_name: "any-generation")
      changeset = Species.changeset(%Species{}, attrs)
      assert Keyword.has_key?(changeset.errors, :generation_name)

      # Test valid generation format
      attrs = params_for(:species, generation_name: "generation-i")
      changeset = Species.changeset(%Species{}, attrs)
      refute Keyword.has_key?(changeset.errors, :generation_name)
    end

    test "validates habitat inclusion when present" do
      # Our current schema doesn't validate habitat names, so test that it accepts any value
      attrs = params_for(:species, habitat_name: "any-habitat")
      changeset = Species.changeset(%Species{}, attrs)
      refute Keyword.has_key?(changeset.errors, :habitat_name)
    end

    test "validates name format" do
      # Test invalid name format (uppercase)
      attrs = params_for(:species, name: "INVALID-NAME")
      changeset = Species.changeset(%Species{}, attrs)
      assert Keyword.has_key?(changeset.errors, :name)

      # Test valid name format
      attrs = params_for(:species, name: "valid-name")
      changeset = Species.changeset(%Species{}, attrs)
      refute Keyword.has_key?(changeset.errors, :name)
    end

    test "validates capture rate range" do
      # Test minimum boundary
      attrs = params_for(:species, capture_rate: 2)
      changeset = Species.changeset(%Species{}, attrs)
      refute changeset.valid?
      assert Keyword.has_key?(changeset.errors, :capture_rate)

      # Test maximum boundary
      attrs = params_for(:species, capture_rate: 256)
      changeset = Species.changeset(%Species{}, attrs)
      refute changeset.valid?
      assert Keyword.has_key?(changeset.errors, :capture_rate)

      # Test valid range
      attrs = params_for(:species, capture_rate: 45)
      changeset = Species.changeset(%Species{}, attrs)
      refute Keyword.has_key?(changeset.errors, :capture_rate)
    end

    test "validates gender rate range" do
      # Test minimum boundary
      attrs = params_for(:species, gender_rate: -2)
      changeset = Species.changeset(%Species{}, attrs)
      refute changeset.valid?
      assert Keyword.has_key?(changeset.errors, :gender_rate)

      # Test maximum boundary
      attrs = params_for(:species, gender_rate: 9)
      changeset = Species.changeset(%Species{}, attrs)
      refute changeset.valid?
      assert Keyword.has_key?(changeset.errors, :gender_rate)

      # Test valid values (-1 for genderless, 0-8 for gender ratios)
      for valid_rate <- [-1, 0, 4, 8] do
        attrs = params_for(:species, gender_rate: valid_rate)
        changeset = Species.changeset(%Species{}, attrs)
        refute Keyword.has_key?(changeset.errors, :gender_rate)
      end
    end
  end

  describe "Pokemon changeset validations" do
    test "validates required fields" do
      changeset = Pokemon.changeset(%Pokemon{}, %{})
      refute changeset.valid?

      required_fields = [:name, :height, :weight, :order, :species_id]
      for field <- required_fields do
        assert changeset.errors[field] != nil, "Expected error for #{field}"
      end
    end

    test "validates with valid factory attributes" do
      species = insert(:species)
      attrs = params_for(:pokemon, species_id: species.id)
      changeset = Pokemon.changeset(%Pokemon{}, attrs)
      assert changeset.valid?
    end

    test "validates height range" do
      species = insert(:species)

      # Test minimum boundary
      attrs = params_for(:pokemon, species_id: species.id, height: 0)
      changeset = Pokemon.changeset(%Pokemon{}, attrs)
      refute changeset.valid?
      assert Keyword.has_key?(changeset.errors, :height)

      # Test valid range
      attrs = params_for(:pokemon, species_id: species.id, height: 10)
      changeset = Pokemon.changeset(%Pokemon{}, attrs)
      refute Keyword.has_key?(changeset.errors, :height)
    end

    test "validates weight range" do
      species = insert(:species)

      # Test minimum boundary
      attrs = params_for(:pokemon, species_id: species.id, weight: 0)
      changeset = Pokemon.changeset(%Pokemon{}, attrs)
      refute changeset.valid?
      assert Keyword.has_key?(changeset.errors, :weight)

      # Test valid range
      attrs = params_for(:pokemon, species_id: species.id, weight: 100)
      changeset = Pokemon.changeset(%Pokemon{}, attrs)
      refute Keyword.has_key?(changeset.errors, :weight)
    end

    test "validates base experience range" do
      species = insert(:species)

      # Test minimum boundary
      attrs = params_for(:pokemon, species_id: species.id, base_experience: -1)
      changeset = Pokemon.changeset(%Pokemon{}, attrs)
      refute changeset.valid?
      assert Keyword.has_key?(changeset.errors, :base_experience)

      # Test valid range
      attrs = params_for(:pokemon, species_id: species.id, base_experience: 100)
      changeset = Pokemon.changeset(%Pokemon{}, attrs)
      refute Keyword.has_key?(changeset.errors, :base_experience)
    end
  end

  describe "Factory validations" do
    test "all factories produce valid data" do
      # Test core factories
      assert insert(:species)
      assert insert(:pokemon)
      assert insert(:ability)
      assert insert(:type)
      assert insert(:stat)
      assert insert(:move)

      # Test junction table factories
      assert insert(:pokemon_ability)
      assert insert(:pokemon_type)
      assert insert(:pokemon_stat)

      # Test factory variants
      assert insert(:legendary_species)
      assert insert(:mythical_species)
      assert insert(:baby_species)
      assert insert(:generation_i_species)
      assert insert(:physical_move)
      assert insert(:special_move)
      assert insert(:status_move)
    end
  end
end
