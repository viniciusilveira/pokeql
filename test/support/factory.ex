defmodule Pokeql.Factory do
  @moduledoc """
  ExMachina factory for generating test data for Pokemon schemas.
  """

  use ExMachina.Ecto, repo: Pokeql.Repo

  # ============================================================================
  # CORE SPECIES FACTORY
  # ============================================================================

  def species_factory do
    %Pokeql.Pokemon.Species{
      name: sequence("species_name", &"species-#{&1}"),
      generation_name: random_generation(),
      color_name: Enum.random(~w[red blue green yellow purple brown black white gray pink]),
      shape_name: Enum.random(~w[ball quadruped fish blob humanoid bug flying dragon plant]),
      habitat_name: Enum.random(~w[cave city forest grassland mountain rare rough-terrain sea urban water-edge]),
      growth_rate_name: Enum.random(~w[slow medium fast medium-slow slow-then-very-fast fast-then-very-slow]),
      gender_rate: Enum.random(-1..8),
      capture_rate: Enum.random(3..255),
      base_happiness: Enum.random(0..140),
      is_baby: Enum.random([true, false]),
      hatch_counter: Enum.random(5..120),
      has_gender_differences: Enum.random([true, false]),
      is_legendary: Enum.random([true, false]),
      is_mythical: Enum.random([true, false])
    }
  end

  # ============================================================================
  # CORE POKEMON FACTORY
  # ============================================================================

  def pokemon_factory do
    %Pokeql.Pokemon{
      name: sequence("pokemon_name", &"pokemon-#{&1}"),
      height: Enum.random(1..200),
      weight: Enum.random(1..9999),
      base_experience: Enum.random(50..300),
      order: sequence("pokemon_order"),
      is_default: true,
      species: build(:species)
    }
  end

  # ============================================================================
  # ABILITY FACTORY
  # ============================================================================

  def ability_factory do
    %Pokeql.Pokemon.Ability{
      name: sequence("ability_name", &"ability-#{&1}"),
      generation_name: random_generation(),
      is_main_series: true,
      short_effect: Faker.Lorem.sentence(5..15)
    }
  end

  # ============================================================================
  # TYPE FACTORY
  # ============================================================================

  def type_factory do
    %Pokeql.Pokemon.Type{
      name: sequence("type_name", &"type-#{&1}"),
      generation_name: random_generation(),
      damage_class_name: Enum.random(~w[physical special status])
    }
  end

  # ============================================================================
  # STAT FACTORY
  # ============================================================================

  def stat_factory do
    %Pokeql.Pokemon.Stat{
      name: sequence("stat_name", &"stat-#{&1}"),
      game_index: sequence("stat_game_index"),
      is_battle_only: Enum.random([true, false])
    }
  end

  # ============================================================================
  # MOVE FACTORY
  # ============================================================================

  def move_factory do
    %Pokeql.Pokemon.Move{
      name: sequence("move_name", &"move-#{&1}"),
      generation_name: random_generation(),
      type_name: "normal",
      damage_class_name: Enum.random(~w[physical special status]),
      power: Enum.random([nil, 20, 40, 60, 80, 90, 100, 120]),
      pp: Enum.random(5..40),
      accuracy: Enum.random([nil, 50, 75, 85, 90, 95, 100]),
      priority: Enum.random(-5..5),
      short_effect: Faker.Lorem.sentence(3..8)
    }
  end

  # ============================================================================
  # JUNCTION TABLE FACTORIES
  # ============================================================================

  def pokemon_ability_factory do
    %Pokeql.Pokemon.PokemonAbility{
      pokemon: build(:pokemon),
      ability: build(:ability),
      slot: Enum.random(1..3),
      is_hidden: false
    }
  end

  def pokemon_ability_hidden_factory do
    build(:pokemon_ability, slot: 3, is_hidden: true)
  end

  def pokemon_type_factory do
    %Pokeql.Pokemon.PokemonType{
      pokemon: build(:pokemon),
      type: build(:type),
      slot: Enum.random(1..2)
    }
  end

  def pokemon_stat_factory do
    %Pokeql.Pokemon.PokemonStat{
      pokemon: build(:pokemon),
      stat: build(:stat),
      base_stat: Enum.random(10..255),
      effort: Enum.random(0..3)
    }
  end

  # ============================================================================
  # HELPER FUNCTIONS
  # ============================================================================

  defp random_generation do
    Enum.random(~w[
      generation-i generation-ii generation-iii generation-iv
      generation-v generation-vi generation-vii generation-viii generation-ix
    ])
  end

  # ============================================================================
  # FACTORY TRAITS AND VARIANTS
  # ============================================================================

  def legendary_species_factory do
    build(:species, is_legendary: true, is_mythical: false)
  end

  def mythical_species_factory do
    build(:species, is_legendary: false, is_mythical: true)
  end

  def baby_species_factory do
    build(:species, is_baby: true, base_happiness: 70, hatch_counter: 10)
  end

  def starter_pokemon_factory do
    build(:pokemon, is_default: true, base_experience: 64)
  end

  def generation_i_species_factory do
    build(:species, generation_name: "generation-i")
  end

  def physical_move_factory do
    build(:move, damage_class_name: "physical", power: Enum.random([60, 80, 100, 120]))
  end

  def special_move_factory do
    build(:move, damage_class_name: "special", power: Enum.random([60, 80, 100, 120]))
  end

  def status_move_factory do
    build(:move, damage_class_name: "status", power: nil)
  end
end
