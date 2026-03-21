defmodule Pokeql.PokemonFetcher do
  @moduledoc """
  Fetches a single Pokemon from PokeAPI and persists all related data.
  Used as the step-3 fallback in the lazy cache strategy when a Pokemon
  is not found in the ETS cache or the DB.
  """

  alias Pokeql.Repo
  alias Pokeql.Pokemon
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

  @spec fetch_and_persist(integer() | String.t()) :: {:ok, Pokemon.t()} | {:error, term()}
  def fetch_and_persist(identifier) do
    poke_api = Application.get_env(:pokeql, :poke_api)

    with {:ok, pokemon_raw} <- poke_api.get_pokemon(identifier),
         species_name = pokemon_raw["species"]["name"],
         {:ok, species_raw} <- poke_api.get_species(species_name) do
      ability_names = Transformer.extract_ability_names(pokemon_raw)
      type_names = Transformer.extract_type_names(pokemon_raw)
      stat_names = Transformer.extract_stat_names(pokemon_raw)
      move_names = Transformer.extract_move_names(pokemon_raw)
      version_group_names = Transformer.extract_version_group_names(pokemon_raw)

      abilities_raw = fetch_all(poke_api, :get_ability, ability_names)
      types_raw = fetch_all(poke_api, :get_type, type_names)
      stats_raw = fetch_all(poke_api, :get_stat, stat_names)
      moves_raw = fetch_all(poke_api, :get_move, move_names)
      version_groups_raw = fetch_all(poke_api, :get_version_group, version_group_names)

      game_version_names =
        version_groups_raw
        |> Enum.flat_map(fn vg -> Enum.map(vg["versions"], & &1["name"]) end)
        |> Enum.uniq()
        |> Enum.sort()

      game_versions_raw = fetch_all(poke_api, :get_game_version, game_version_names)

      insert_all_idempotent(
        VersionGroup,
        Enum.map(version_groups_raw, &Transformer.version_group_attrs/1)
      )

      insert_all_idempotent(
        GameVersion,
        Enum.map(game_versions_raw, &Transformer.game_version_attrs/1)
      )

      insert_all_idempotent(Species, [Transformer.species_attrs(species_raw)])
      insert_all_idempotent(Ability, Enum.map(abilities_raw, &Transformer.ability_attrs/1))
      insert_all_idempotent(Type, Enum.map(types_raw, &Transformer.type_attrs/1))
      insert_all_idempotent(Stat, Enum.map(stats_raw, &Transformer.stat_attrs/1))
      insert_all_idempotent(Move, Enum.map(moves_raw, &Transformer.move_attrs/1))

      species_map = Repo.all(from s in Species, select: {s.name, s.id}) |> Map.new()
      ability_map = Repo.all(from a in Ability, select: {a.name, a.id}) |> Map.new()
      type_map = Repo.all(from t in Type, select: {t.name, t.id}) |> Map.new()
      stat_map = Repo.all(from s in Stat, select: {s.name, s.id}) |> Map.new()
      move_map = Repo.all(from m in Move, select: {m.name, m.id}) |> Map.new()
      game_version_map = Repo.all(from g in GameVersion, select: {g.name, g.id}) |> Map.new()

      species_id = Map.fetch!(species_map, species_name)
      pokemon_entry = Transformer.pokemon_attrs(pokemon_raw) |> Map.put(:species_id, species_id)
      insert_all_idempotent(Pokemon, [pokemon_entry])

      pokemon_map = Repo.all(from p in Pokemon, select: {p.name, p.id}) |> Map.new()
      pokemon_id = Map.fetch!(pokemon_map, pokemon_raw["name"])

      ability_entries =
        Transformer.pokemon_abilities_attrs(pokemon_raw)
        |> Enum.map(fn attrs ->
          ability_id = Map.fetch!(ability_map, attrs.ability_name)

          attrs
          |> Map.delete(:ability_name)
          |> Map.put(:pokemon_id, pokemon_id)
          |> Map.put(:ability_id, ability_id)
        end)

      type_entries =
        Transformer.pokemon_types_attrs(pokemon_raw)
        |> Enum.map(fn attrs ->
          type_id = Map.fetch!(type_map, attrs.type_name)

          attrs
          |> Map.delete(:type_name)
          |> Map.put(:pokemon_id, pokemon_id)
          |> Map.put(:type_id, type_id)
        end)

      stat_entries =
        Transformer.pokemon_stats_attrs(pokemon_raw)
        |> Enum.map(fn attrs ->
          stat_id = Map.fetch!(stat_map, attrs.stat_name)

          attrs
          |> Map.delete(:stat_name)
          |> Map.put(:pokemon_id, pokemon_id)
          |> Map.put(:stat_id, stat_id)
        end)

      move_entries =
        Transformer.pokemon_moves_attrs(pokemon_raw)
        |> Enum.map(fn attrs ->
          move_id = Map.fetch!(move_map, attrs.move_name)

          attrs
          |> Map.delete(:move_name)
          |> Map.put(:pokemon_id, pokemon_id)
          |> Map.put(:move_id, move_id)
        end)

      sprite_entry = Transformer.sprite_attrs(pokemon_raw) |> Map.put(:pokemon_id, pokemon_id)

      game_index_entries =
        pokemon_raw["game_indices"]
        |> Enum.flat_map(fn gi ->
          version_name = gi["version"]["name"]

          case Map.get(game_version_map, version_name) do
            nil ->
              []

            game_version_id ->
              [
                %{
                  pokemon_id: pokemon_id,
                  game_version_id: game_version_id,
                  game_index: gi["game_index"]
                }
              ]
          end
        end)

      insert_all_idempotent(PokemonAbility, ability_entries)
      insert_all_idempotent(PokemonType, type_entries)
      insert_all_idempotent(PokemonStat, stat_entries)
      insert_all_idempotent(PokemonMove, move_entries)
      insert_all_idempotent(Sprite, [sprite_entry])
      insert_all_idempotent(PokemonGameIndex, game_index_entries)

      pokemon =
        Pokemon
        |> where([p], p.id == ^pokemon_id)
        |> preload(^Pokemon.full_preloads())
        |> Repo.one()
        |> Pokemon.populate_virtual_fields()

      {:ok, pokemon}
    end
  end

  defp fetch_all(_poke_api, _fun, []), do: []

  defp fetch_all(poke_api, fun, names) do
    Enum.map(names, fn name ->
      {:ok, raw} = apply(poke_api, fun, [name])
      raw
    end)
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
