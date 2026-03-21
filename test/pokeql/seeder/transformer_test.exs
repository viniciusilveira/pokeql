defmodule Pokeql.Seeder.TransformerTest do
  use ExUnit.Case, async: true

  alias Pokeql.PokeAPIFixtures, as: Fixtures
  alias Pokeql.Seeder.Transformer

  describe "species_attrs/1" do
    test "returns atom-keyed map from species data" do
      {:ok, raw} = Fixtures.bulbasaur_species()

      attrs = Transformer.species_attrs(raw)

      assert attrs.name == "bulbasaur"
      assert attrs.generation_name == "generation-i"
      assert attrs.color_name == "green"
      assert attrs.shape_name == "quadruped"
      assert attrs.habitat_name == "grassland"
      assert attrs.growth_rate_name == "medium-slow"
      assert attrs.gender_rate == 1
      assert attrs.capture_rate == 45
      assert attrs.base_happiness == 50
      assert attrs.is_baby == false
      assert attrs.hatch_counter == 20
      assert attrs.has_gender_differences == false
      assert attrs.is_legendary == false
      assert attrs.is_mythical == false
    end
  end

  describe "pokemon_attrs/1" do
    test "returns atom-keyed map from pokemon data" do
      {:ok, raw} = Fixtures.bulbasaur_pokemon()

      attrs = Transformer.pokemon_attrs(raw)

      assert attrs.name == "bulbasaur"
      assert attrs.height == 7
      assert attrs.weight == 69
      assert attrs.base_experience == 64
      assert attrs.order == 1
      assert attrs.is_default == true
    end
  end

  describe "ability_attrs/1" do
    test "returns atom-keyed map from ability data" do
      {:ok, raw} = Fixtures.overgrow_ability()

      attrs = Transformer.ability_attrs(raw)

      assert attrs.name == "overgrow"
      assert attrs.generation_name == "generation-iii"
      assert attrs.is_main_series == true

      assert attrs.short_effect ==
               "Strengthens grass moves to inflict 1.5× damage at 1/3 max HP or less."
    end
  end

  describe "type_attrs/1" do
    test "returns atom-keyed map from type data" do
      {:ok, raw} = Fixtures.grass_type()

      attrs = Transformer.type_attrs(raw)

      assert attrs.name == "grass"
      assert attrs.generation_name == "generation-i"
      assert attrs.damage_class_name == "special"
    end
  end

  describe "stat_attrs/1" do
    test "returns atom-keyed map from stat data" do
      {:ok, raw} = Fixtures.hp_stat()

      attrs = Transformer.stat_attrs(raw)

      assert attrs.name == "hp"
      assert attrs.game_index == 1
      assert attrs.is_battle_only == false
    end
  end

  describe "move_attrs/1" do
    test "returns atom-keyed map from move data" do
      {:ok, raw} = Fixtures.tackle_move()

      attrs = Transformer.move_attrs(raw)

      assert attrs.name == "tackle"
      assert attrs.generation_name == "generation-i"
      assert attrs.type_name == "normal"
      assert attrs.damage_class_name == "physical"
      assert attrs.power == 40
      assert attrs.pp == 35
      assert attrs.accuracy == 100
      assert attrs.priority == 0
      assert attrs.short_effect == "Inflicts regular damage with no additional effect."
    end

    test "converts accuracy and power of 0 to nil" do
      raw = %{
        "name" => "dragon-cheer",
        "generation" => %{"name" => "generation-ix"},
        "type" => %{"name" => "dragon"},
        "damage_class" => %{"name" => "status"},
        "power" => 0,
        "pp" => 15,
        "accuracy" => 0,
        "priority" => 0,
        "effect_entries" => []
      }

      attrs = Transformer.move_attrs(raw)

      assert attrs.accuracy == nil
      assert attrs.power == nil
    end
  end

  describe "version_group_attrs/1" do
    test "returns atom-keyed map from version group data" do
      {:ok, raw} = Fixtures.red_blue_version_group()

      attrs = Transformer.version_group_attrs(raw)

      assert attrs.name == "red-blue"
      assert attrs.generation_name == "generation-i"
      assert attrs.sort_order == 1
    end
  end

  describe "game_version_attrs/1" do
    test "returns atom-keyed map from game version data" do
      {:ok, raw} = Fixtures.red_game_version()

      attrs = Transformer.game_version_attrs(raw)

      assert attrs.name == "red"
      assert attrs.version_group_name == "red-blue"
    end
  end

  describe "pokemon_abilities_attrs/1" do
    test "returns list of ability association maps" do
      {:ok, raw} = Fixtures.bulbasaur_pokemon()

      attrs = Transformer.pokemon_abilities_attrs(raw)

      assert length(attrs) == 2
      overgrow = Enum.find(attrs, &(&1.ability_name == "overgrow"))
      assert overgrow.slot == 1
      assert overgrow.is_hidden == false

      chlorophyll = Enum.find(attrs, &(&1.ability_name == "chlorophyll"))
      assert chlorophyll.slot == 3
      assert chlorophyll.is_hidden == true
    end
  end

  describe "pokemon_types_attrs/1" do
    test "returns list of type association maps" do
      {:ok, raw} = Fixtures.bulbasaur_pokemon()

      attrs = Transformer.pokemon_types_attrs(raw)

      assert length(attrs) == 2
      grass = Enum.find(attrs, &(&1.type_name == "grass"))
      assert grass.slot == 1

      poison = Enum.find(attrs, &(&1.type_name == "poison"))
      assert poison.slot == 2
    end
  end

  describe "pokemon_stats_attrs/1" do
    test "returns list of stat association maps" do
      {:ok, raw} = Fixtures.bulbasaur_pokemon()

      attrs = Transformer.pokemon_stats_attrs(raw)

      assert length(attrs) == 6
      hp = Enum.find(attrs, &(&1.stat_name == "hp"))
      assert hp.base_stat == 45
      assert hp.effort == 0

      sp_atk = Enum.find(attrs, &(&1.stat_name == "special-attack"))
      assert sp_atk.base_stat == 65
      assert sp_atk.effort == 1
    end
  end

  describe "pokemon_moves_attrs/1" do
    test "returns list of move association maps" do
      {:ok, raw} = Fixtures.bulbasaur_pokemon()

      attrs = Transformer.pokemon_moves_attrs(raw)

      assert length(attrs) == 1
      assert hd(attrs).move_name == "tackle"
    end
  end

  describe "sprite_attrs/1" do
    test "returns single sprite map" do
      {:ok, raw} = Fixtures.bulbasaur_pokemon()

      attrs = Transformer.sprite_attrs(raw)

      assert attrs.front_default ==
               "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png"

      assert attrs.back_default ==
               "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png"

      assert attrs.front_shiny ==
               "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png"

      assert attrs.back_shiny ==
               "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/1.png"

      assert is_nil(attrs.front_female)
      assert is_nil(attrs.back_female)
      assert is_nil(attrs.front_shiny_female)
      assert is_nil(attrs.back_shiny_female)
    end
  end

  describe "extract_pokemon_name/1" do
    test "returns the default variety pokemon name" do
      {:ok, raw} = Fixtures.bulbasaur_species()

      name = Transformer.extract_pokemon_name(raw)

      assert name == "bulbasaur"
    end
  end

  describe "extract_ability_names/1" do
    test "returns sorted list of ability names" do
      {:ok, raw} = Fixtures.bulbasaur_pokemon()

      names = Transformer.extract_ability_names(raw)

      assert names == ["chlorophyll", "overgrow"]
    end
  end

  describe "extract_type_names/1" do
    test "returns sorted list of type names" do
      {:ok, raw} = Fixtures.bulbasaur_pokemon()

      names = Transformer.extract_type_names(raw)

      assert names == ["grass", "poison"]
    end
  end

  describe "extract_stat_names/1" do
    test "returns sorted list of stat names" do
      {:ok, raw} = Fixtures.bulbasaur_pokemon()

      names = Transformer.extract_stat_names(raw)

      assert names == ["attack", "defense", "hp", "special-attack", "special-defense", "speed"]
    end
  end

  describe "extract_move_names/1" do
    test "returns sorted list of move names" do
      {:ok, raw} = Fixtures.bulbasaur_pokemon()

      names = Transformer.extract_move_names(raw)

      assert names == ["tackle"]
    end
  end

  describe "extract_version_group_names/1" do
    test "returns sorted unique list of version group names from move details" do
      {:ok, raw} = Fixtures.bulbasaur_pokemon()

      names = Transformer.extract_version_group_names(raw)

      assert names == ["red-blue"]
    end
  end
end
