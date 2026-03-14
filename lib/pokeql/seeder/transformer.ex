defmodule Pokeql.Seeder.Transformer do
  @moduledoc """
  Pure transformation functions for converting raw PokeAPI responses
  into maps suitable for Ecto schema insertion.

  All functions are side-effect-free and work only with the data provided.
  """

  def species_attrs(raw) do
    %{
      name: raw["name"],
      generation_name: raw["generation"]["name"],
      color_name: raw["color"]["name"],
      shape_name: raw["shape"]["name"],
      habitat_name: get_in(raw, ["habitat", "name"]),
      growth_rate_name: raw["growth_rate"]["name"],
      gender_rate: raw["gender_rate"],
      capture_rate: raw["capture_rate"],
      base_happiness: raw["base_happiness"],
      is_baby: raw["is_baby"],
      hatch_counter: raw["hatch_counter"],
      has_gender_differences: raw["has_gender_differences"],
      is_legendary: raw["is_legendary"],
      is_mythical: raw["is_mythical"]
    }
  end

  def pokemon_attrs(raw) do
    %{
      name: raw["name"],
      height: raw["height"],
      weight: raw["weight"],
      base_experience: raw["base_experience"],
      order: raw["order"],
      is_default: raw["is_default"]
    }
  end

  def ability_attrs(raw) do
    short_effect =
      raw["effect_entries"]
      |> Enum.find(%{}, fn e -> e["language"]["name"] == "en" end)
      |> Map.get("short_effect", "")

    %{
      name: raw["name"],
      generation_name: raw["generation"]["name"],
      is_main_series: raw["is_main_series"],
      short_effect: short_effect
    }
  end

  def type_attrs(raw) do
    %{
      name: raw["name"],
      generation_name: raw["generation"]["name"],
      damage_class_name: get_in(raw, ["move_damage_class", "name"])
    }
  end

  def stat_attrs(raw) do
    %{
      name: raw["name"],
      game_index: raw["game_index"],
      is_battle_only: raw["is_battle_only"]
    }
  end

  def move_attrs(raw) do
    short_effect =
      raw["effect_entries"]
      |> Enum.find(%{}, fn e -> e["language"]["name"] == "en" end)
      |> Map.get("short_effect", "")

    %{
      name: raw["name"],
      generation_name: raw["generation"]["name"],
      type_name: raw["type"]["name"],
      damage_class_name: get_in(raw, ["damage_class", "name"]),
      power: nil_if_zero(raw["power"]),
      pp: raw["pp"],
      accuracy: nil_if_zero(raw["accuracy"]),
      priority: raw["priority"],
      short_effect: short_effect
    }
  end

  def version_group_attrs(raw) do
    %{
      name: raw["name"],
      generation_name: raw["generation"]["name"],
      sort_order: raw["order"]
    }
  end

  def game_version_attrs(raw) do
    %{
      name: raw["name"],
      version_group_name: raw["version_group"]["name"]
    }
  end

  def pokemon_abilities_attrs(raw) do
    raw["abilities"]
    |> Enum.map(fn a ->
      %{slot: a["slot"], is_hidden: a["is_hidden"], ability_name: a["ability"]["name"]}
    end)
  end

  def pokemon_types_attrs(raw) do
    raw["types"]
    |> Enum.map(fn t ->
      %{slot: t["slot"], type_name: t["type"]["name"]}
    end)
  end

  def pokemon_stats_attrs(raw) do
    raw["stats"]
    |> Enum.map(fn s ->
      %{base_stat: s["base_stat"], effort: s["effort"], stat_name: s["stat"]["name"]}
    end)
  end

  def pokemon_moves_attrs(raw) do
    raw["moves"]
    |> Enum.map(fn m ->
      %{move_name: m["move"]["name"]}
    end)
  end

  def sprite_attrs(raw) do
    sprites = raw["sprites"]

    %{
      front_default: sprites["front_default"],
      back_default: sprites["back_default"],
      front_shiny: sprites["front_shiny"],
      back_shiny: sprites["back_shiny"],
      front_female: sprites["front_female"],
      back_female: sprites["back_female"],
      front_shiny_female: sprites["front_shiny_female"],
      back_shiny_female: sprites["back_shiny_female"]
    }
  end

  def extract_pokemon_name(species_raw) do
    species_raw["varieties"]
    |> Enum.find(fn v -> v["is_default"] end)
    |> get_in(["pokemon", "name"])
  end

  def extract_ability_names(pokemon_raw) do
    pokemon_raw["abilities"]
    |> Enum.map(fn a -> a["ability"]["name"] end)
    |> Enum.sort()
  end

  def extract_type_names(pokemon_raw) do
    pokemon_raw["types"]
    |> Enum.map(fn t -> t["type"]["name"] end)
    |> Enum.sort()
  end

  def extract_stat_names(pokemon_raw) do
    pokemon_raw["stats"]
    |> Enum.map(fn s -> s["stat"]["name"] end)
    |> Enum.sort()
  end

  def extract_move_names(pokemon_raw) do
    pokemon_raw["moves"]
    |> Enum.map(fn m -> m["move"]["name"] end)
    |> Enum.sort()
  end

  defp nil_if_zero(0), do: nil
  defp nil_if_zero(val), do: val

  def extract_version_group_names(pokemon_raw) do
    pokemon_raw["moves"]
    |> Enum.flat_map(fn m ->
      m["version_group_details"]
      |> Enum.map(fn vgd -> vgd["version_group"]["name"] end)
    end)
    |> Enum.uniq()
    |> Enum.sort()
  end
end
