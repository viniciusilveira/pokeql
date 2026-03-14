defmodule Pokeql.Seeder.Seeder do
  @moduledoc """
  Seeds the database with Generation 1 Pokemon data from the PokeAPI.

  Fetches all 151 Generation 1 Pokemon (or however many the API returns)
  and inserts them into PostgreSQL along with all reference data.

  Uses `on_conflict: :nothing` for idempotent inserts.
  """

  alias Pokeql.Repo
  alias Pokeql.Seeder.Transformer

  alias Pokeql.Pokemon.Species
  alias Pokeql.Pokemon.Ability
  alias Pokeql.Pokemon.Type
  alias Pokeql.Pokemon.Stat
  alias Pokeql.Pokemon.Move
  alias Pokeql.Pokemon.VersionGroup
  alias Pokeql.Pokemon.GameVersion
  alias Pokeql.Pokemon.PokemonAbility
  alias Pokeql.Pokemon.PokemonType
  alias Pokeql.Pokemon.PokemonStat
  alias Pokeql.Pokemon.PokemonMove
  alias Pokeql.Pokemon.Sprite
  alias Pokeql.Pokemon.PokemonGameIndex

  import Ecto.Query

  def run do
    poke_api = Application.get_env(:pokeql, :poke_api)

    # Step 1: Fetch generation to get species + version group names
    {:ok, gen_raw} = poke_api.get_generation("generation-i")
    species_names = gen_raw["pokemon_species"] |> Enum.map(& &1["name"])
    version_group_names_from_gen = gen_raw["version_groups"] |> Enum.map(& &1["name"])

    # Step 2: Fetch all species
    species_raw_list =
      Enum.map(species_names, fn name ->
        {:ok, raw} = poke_api.get_species(name)
        raw
      end)

    # Extract default pokemon names from species
    pokemon_names = Enum.map(species_raw_list, &Transformer.extract_pokemon_name/1)

    # Step 3: Fetch all pokemons
    pokemon_raw_list =
      Enum.map(pokemon_names, fn name ->
        {:ok, raw} = poke_api.get_pokemon(name)
        raw
      end)

    # Step 4: Collect unique names from pokemon data
    ability_names =
      pokemon_raw_list
      |> Enum.flat_map(&Transformer.extract_ability_names/1)
      |> Enum.uniq()
      |> Enum.sort()

    type_names =
      pokemon_raw_list
      |> Enum.flat_map(&Transformer.extract_type_names/1)
      |> Enum.uniq()
      |> Enum.sort()

    stat_names =
      pokemon_raw_list
      |> Enum.flat_map(&Transformer.extract_stat_names/1)
      |> Enum.uniq()
      |> Enum.sort()

    move_names =
      pokemon_raw_list
      |> Enum.flat_map(&Transformer.extract_move_names/1)
      |> Enum.uniq()
      |> Enum.sort()

    version_group_names_from_moves =
      pokemon_raw_list
      |> Enum.flat_map(&Transformer.extract_version_group_names/1)
      |> Enum.uniq()

    version_group_names =
      (version_group_names_from_gen ++ version_group_names_from_moves)
      |> Enum.uniq()
      |> Enum.sort()

    # Step 5: Fetch reference data
    abilities_raw =
      Enum.map(ability_names, fn name ->
        {:ok, raw} = poke_api.get_ability(name)
        raw
      end)

    types_raw =
      Enum.map(type_names, fn name ->
        {:ok, raw} = poke_api.get_type(name)
        raw
      end)

    stats_raw =
      Enum.map(stat_names, fn name ->
        {:ok, raw} = poke_api.get_stat(name)
        raw
      end)

    moves_raw =
      Enum.map(move_names, fn name ->
        {:ok, raw} = poke_api.get_move(name)
        raw
      end)

    version_groups_raw =
      Enum.map(version_group_names, fn name ->
        {:ok, raw} = poke_api.get_version_group(name)
        raw
      end)

    # Extract game version names from version groups
    game_version_names =
      version_groups_raw
      |> Enum.flat_map(fn vg -> Enum.map(vg["versions"], & &1["name"]) end)
      |> Enum.uniq()
      |> Enum.sort()

    game_versions_raw =
      Enum.map(game_version_names, fn name ->
        {:ok, raw} = poke_api.get_game_version(name)
        raw
      end)

    # Step 6: Insert reference tables
    insert_all_idempotent(VersionGroup, Enum.map(version_groups_raw, &Transformer.version_group_attrs/1))
    insert_all_idempotent(GameVersion, Enum.map(game_versions_raw, &Transformer.game_version_attrs/1))
    insert_all_idempotent(Species, Enum.map(species_raw_list, &Transformer.species_attrs/1))
    insert_all_idempotent(Ability, Enum.map(abilities_raw, &Transformer.ability_attrs/1))
    insert_all_idempotent(Type, Enum.map(types_raw, &Transformer.type_attrs/1))
    insert_all_idempotent(Stat, Enum.map(stats_raw, &Transformer.stat_attrs/1))
    insert_all_idempotent(Move, Enum.map(moves_raw, &Transformer.move_attrs/1))

    # Build lookup maps
    species_map = Repo.all(from s in Species, select: {s.name, s.id}) |> Map.new()
    ability_map = Repo.all(from a in Ability, select: {a.name, a.id}) |> Map.new()
    type_map = Repo.all(from t in Type, select: {t.name, t.id}) |> Map.new()
    stat_map = Repo.all(from s in Stat, select: {s.name, s.id}) |> Map.new()
    move_map = Repo.all(from m in Move, select: {m.name, m.id}) |> Map.new()
    game_version_map = Repo.all(from g in GameVersion, select: {g.name, g.id}) |> Map.new()

    # Step 7: Insert pokemons
    pokemon_entries =
      Enum.zip(species_raw_list, pokemon_raw_list)
      |> Enum.map(fn {species_raw, pokemon_raw} ->
        species_name = species_raw["name"]
        species_id = Map.fetch!(species_map, species_name)

        Transformer.pokemon_attrs(pokemon_raw)
        |> Map.put(:species_id, species_id)
      end)

    insert_all_idempotent(Pokeql.Pokemon, pokemon_entries)

    pokemon_map = Repo.all(from p in Pokeql.Pokemon, select: {p.name, p.id}) |> Map.new()

    # Step 8: Insert junction tables

    pokemon_ability_entries =
      Enum.flat_map(pokemon_raw_list, fn pokemon_raw ->
        pokemon_id = Map.fetch!(pokemon_map, pokemon_raw["name"])

        Transformer.pokemon_abilities_attrs(pokemon_raw)
        |> Enum.map(fn attrs ->
          ability_id = Map.fetch!(ability_map, attrs.ability_name)

          attrs
          |> Map.delete(:ability_name)
          |> Map.put(:pokemon_id, pokemon_id)
          |> Map.put(:ability_id, ability_id)
        end)
      end)

    insert_all_idempotent(PokemonAbility, pokemon_ability_entries)

    pokemon_type_entries =
      Enum.flat_map(pokemon_raw_list, fn pokemon_raw ->
        pokemon_id = Map.fetch!(pokemon_map, pokemon_raw["name"])

        Transformer.pokemon_types_attrs(pokemon_raw)
        |> Enum.map(fn attrs ->
          type_id = Map.fetch!(type_map, attrs.type_name)

          attrs
          |> Map.delete(:type_name)
          |> Map.put(:pokemon_id, pokemon_id)
          |> Map.put(:type_id, type_id)
        end)
      end)

    insert_all_idempotent(PokemonType, pokemon_type_entries)

    pokemon_stat_entries =
      Enum.flat_map(pokemon_raw_list, fn pokemon_raw ->
        pokemon_id = Map.fetch!(pokemon_map, pokemon_raw["name"])

        Transformer.pokemon_stats_attrs(pokemon_raw)
        |> Enum.map(fn attrs ->
          stat_id = Map.fetch!(stat_map, attrs.stat_name)

          attrs
          |> Map.delete(:stat_name)
          |> Map.put(:pokemon_id, pokemon_id)
          |> Map.put(:stat_id, stat_id)
        end)
      end)

    insert_all_idempotent(PokemonStat, pokemon_stat_entries)

    pokemon_move_entries =
      Enum.flat_map(pokemon_raw_list, fn pokemon_raw ->
        pokemon_id = Map.fetch!(pokemon_map, pokemon_raw["name"])

        Transformer.pokemon_moves_attrs(pokemon_raw)
        |> Enum.map(fn attrs ->
          move_id = Map.fetch!(move_map, attrs.move_name)

          attrs
          |> Map.delete(:move_name)
          |> Map.put(:pokemon_id, pokemon_id)
          |> Map.put(:move_id, move_id)
        end)
      end)

    insert_all_idempotent(PokemonMove, pokemon_move_entries)

    # Step 9: Insert sprites
    sprite_entries =
      Enum.map(pokemon_raw_list, fn pokemon_raw ->
        pokemon_id = Map.fetch!(pokemon_map, pokemon_raw["name"])

        Transformer.sprite_attrs(pokemon_raw)
        |> Map.put(:pokemon_id, pokemon_id)
      end)

    insert_all_idempotent(Sprite, sprite_entries)

    # Step 10: Insert game indices
    game_index_entries =
      Enum.flat_map(pokemon_raw_list, fn pokemon_raw ->
        pokemon_id = Map.fetch!(pokemon_map, pokemon_raw["name"])

        pokemon_raw["game_indices"]
        |> Enum.map(fn gi ->
          version_name = gi["version"]["name"]
          game_version_id = Map.get(game_version_map, version_name)

          if game_version_id do
            %{pokemon_id: pokemon_id, game_version_id: game_version_id, game_index: gi["game_index"]}
          else
            nil
          end
        end)
        |> Enum.reject(&is_nil/1)
      end)

    insert_all_idempotent(PokemonGameIndex, game_index_entries)

    :ok
  end

  defp insert_all_idempotent(_schema, []), do: :ok

  defp insert_all_idempotent(schema, entries) do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)

    entries_with_timestamps =
      Enum.map(entries, &Map.merge(&1, %{inserted_at: now, updated_at: now}))

    Repo.insert_all(schema, entries_with_timestamps, on_conflict: :nothing)
    :ok
  end
end
