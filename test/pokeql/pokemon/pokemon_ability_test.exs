defmodule Pokeql.Pokemon.PokemonAbilityTest do
  use Pokeql.DataCase

  alias Pokeql.Pokemon.PokemonAbility

  describe "changeset/2" do
    test "changeset with valid attributes" do
      pokemon = insert(:pokemon)
      ability = insert(:ability)
      attrs = params_for(:pokemon_ability, pokemon_id: pokemon.id, ability_id: ability.id)

      changeset = PokemonAbility.changeset(%PokemonAbility{}, attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      invalid_attrs = %{
        pokemon_id: nil,
        ability_id: nil,
        slot: nil,
        is_hidden: "not_a_boolean"
      }

      changeset = PokemonAbility.changeset(%PokemonAbility{}, invalid_attrs)
      refute changeset.valid?
      errors = errors_on(changeset)

      assert "can't be blank" in errors[:pokemon_id]
      assert "can't be blank" in errors[:ability_id]
      assert "can't be blank" in errors[:slot]
    end

    test "validates slot is between 1 and 3" do
      pokemon = insert(:pokemon)
      ability = insert(:ability)
      base_attrs = %{pokemon_id: pokemon.id, ability_id: ability.id, is_hidden: false}

      # Test invalid slots
      for invalid_slot <- [0, 4, -1] do
        invalid_attrs = Map.put(base_attrs, :slot, invalid_slot)
        changeset = PokemonAbility.changeset(%PokemonAbility{}, invalid_attrs)
        refute changeset.valid?
        assert "must be between 1 and 3" in errors_on(changeset)[:slot]
      end

      # Test valid slots (with proper is_hidden for slot 3)
      for valid_slot <- [1, 2] do
        valid_attrs = Map.put(base_attrs, :slot, valid_slot)
        changeset = PokemonAbility.changeset(%PokemonAbility{}, valid_attrs)
        assert changeset.valid?
      end

      # Test slot 3 with is_hidden: true
      valid_attrs = Map.merge(base_attrs, %{slot: 3, is_hidden: true})
      changeset = PokemonAbility.changeset(%PokemonAbility{}, valid_attrs)
      assert changeset.valid?
    end

    test "validates hidden ability logic" do
      pokemon = insert(:pokemon)
      ability = insert(:ability)

      # Slot 3 must be hidden
      attrs = %{pokemon_id: pokemon.id, ability_id: ability.id, slot: 3, is_hidden: false}
      changeset = PokemonAbility.changeset(%PokemonAbility{}, attrs)
      refute changeset.valid?
      assert "slot 3 abilities must be hidden" in errors_on(changeset)[:is_hidden]

      # Slot 3 should be valid when hidden
      attrs = %{pokemon_id: pokemon.id, ability_id: ability.id, slot: 3, is_hidden: true}
      changeset = PokemonAbility.changeset(%PokemonAbility{}, attrs)
      assert changeset.valid?

      # Only slot 3 can be hidden
      attrs = %{pokemon_id: pokemon.id, ability_id: ability.id, slot: 1, is_hidden: true}
      changeset = PokemonAbility.changeset(%PokemonAbility{}, attrs)
      refute changeset.valid?
      assert "only slot 3 abilities can be hidden" in errors_on(changeset)[:is_hidden]
    end

    test "validates unique constraint on pokemon_id and slot" do
      pokemon_ability = insert(:pokemon_ability)

      # Try to insert another ability for same pokemon and slot
      duplicate_attrs = params_for(:pokemon_ability,
        pokemon_id: pokemon_ability.pokemon_id,
        slot: pokemon_ability.slot
      )

      changeset = PokemonAbility.changeset(%PokemonAbility{}, duplicate_attrs)
      {:error, changeset} = Repo.insert(changeset)
      assert "has already been taken" in errors_on(changeset)[:slot]
    end

    test "validates foreign key constraints" do
      valid_attrs = params_for(:pokemon_ability, pokemon_id: 999999, ability_id: 999999)

      changeset = PokemonAbility.changeset(%PokemonAbility{}, valid_attrs)
      {:error, changeset} = Repo.insert(changeset)

      # Should have foreign key constraint errors
      assert changeset.errors[:pokemon_id] || changeset.errors[:ability_id]
    end
  end

  describe "factory traits" do
    test "pokemon_ability_hidden_factory creates hidden ability" do
      hidden_ability = build(:pokemon_ability_hidden)
      assert hidden_ability.slot == 3
      assert hidden_ability.is_hidden == true
    end

    test "pokemon_ability factory creates regular ability" do
      regular_ability = build(:pokemon_ability)
      assert regular_ability.slot in [1, 2, 3]
      assert regular_ability.is_hidden == false
    end
  end
end
