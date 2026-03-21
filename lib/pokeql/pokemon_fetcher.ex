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

    with {:ok, raw} <- fetch_raw_data(poke_api, identifier) do
      persist_reference_tables(raw)
      id_maps = build_id_maps()
      pokemon_id = persist_pokemon(raw.pokemon, id_maps)
      persist_junction_tables(raw.pokemon, pokemon_id, id_maps)
      load_pokemon(pokemon_id)
    end
  end

  # ---------------------------------------------------------------------------
  # Fetching

  defp fetch_raw_data(poke_api, identifier) do
    with {:ok, pokemon_raw} <- poke_api.get_pokemon(identifier),
         species_name = pokemon_raw["species"]["name"],
         {:ok, species_raw} <- poke_api.get_species(species_name) do
      {:ok, build_raw_map(poke_api, pokemon_raw, species_raw)}
    end
  end

  defp build_raw_map(poke_api, pokemon_raw, species_raw) do
    version_groups_raw =
      pokemon_raw
      |> Transformer.extract_version_group_names()
      |> then(&fetch_all(poke_api, :get_version_group, &1))

    game_version_names =
      version_groups_raw
      |> Enum.flat_map(fn vg -> Enum.map(vg["versions"], & &1["name"]) end)
      |> Enum.uniq()
      |> Enum.sort()

    %{
      pokemon: pokemon_raw,
      species: species_raw,
      abilities: fetch_all(poke_api, :get_ability, Transformer.extract_ability_names(pokemon_raw)),
      types: fetch_all(poke_api, :get_type, Transformer.extract_type_names(pokemon_raw)),
      stats: fetch_all(poke_api, :get_stat, Transformer.extract_stat_names(pokemon_raw)),
      moves: fetch_all(poke_api, :get_move, Transformer.extract_move_names(pokemon_raw)),
      version_groups: version_groups_raw,
      game_versions: fetch_all(poke_api, :get_game_version, game_version_names)
    }
  end

  defp fetch_all(_poke_api, _fun, []), do: []

  defp fetch_all(poke_api, fun, names) do
    Enum.map(names, fn name ->
      {:ok, raw} = apply(poke_api, fun, [name])
      raw
    end)
  end

  # ---------------------------------------------------------------------------
  # Persisting

  defp persist_reference_tables(raw) do
    insert_all_idempotent(VersionGroup, Enum.map(raw.version_groups, &Transformer.version_group_attrs/1))
    insert_all_idempotent(GameVersion, Enum.map(raw.game_versions, &Transformer.game_version_attrs/1))
    insert_all_idempotent(Species, [Transformer.species_attrs(raw.species)])
    insert_all_idempotent(Ability, Enum.map(raw.abilities, &Transformer.ability_attrs/1))
    insert_all_idempotent(Type, Enum.map(raw.types, &Transformer.type_attrs/1))
    insert_all_idempotent(Stat, Enum.map(raw.stats, &Transformer.stat_attrs/1))
    insert_all_idempotent(Move, Enum.map(raw.moves, &Transformer.move_attrs/1))
  end

  defp build_id_maps do
    %{
      species: Repo.all(from s in Species, select: {s.name, s.id}) |> Map.new(),
      ability: Repo.all(from a in Ability, select: {a.name, a.id}) |> Map.new(),
      type: Repo.all(from t in Type, select: {t.name, t.id}) |> Map.new(),
      stat: Repo.all(from s in Stat, select: {s.name, s.id}) |> Map.new(),
      move: Repo.all(from m in Move, select: {m.name, m.id}) |> Map.new(),
      game_version: Repo.all(from g in GameVersion, select: {g.name, g.id}) |> Map.new()
    }
  end

  defp persist_pokemon(pokemon_raw, %{species: species_map}) do
    species_name = pokemon_raw["species"]["name"]
    species_id = Map.fetch!(species_map, species_name)

    pokemon_entry = Transformer.pokemon_attrs(pokemon_raw) |> Map.put(:species_id, species_id)
    insert_all_idempotent(Pokemon, [pokemon_entry])

    pokemon_name = pokemon_raw["name"]
    Repo.one!(from p in Pokemon, where: p.name == ^pokemon_name, select: p.id)
  end

  defp persist_junction_tables(pokemon_raw, pokemon_id, id_maps) do
    insert_all_idempotent(PokemonAbility, ability_entries(pokemon_raw, pokemon_id, id_maps.ability))
    insert_all_idempotent(PokemonType, type_entries(pokemon_raw, pokemon_id, id_maps.type))
    insert_all_idempotent(PokemonStat, stat_entries(pokemon_raw, pokemon_id, id_maps.stat))
    insert_all_idempotent(PokemonMove, move_entries(pokemon_raw, pokemon_id, id_maps.move))
    insert_all_idempotent(Sprite, [sprite_entry(pokemon_raw, pokemon_id)])
    insert_all_idempotent(PokemonGameIndex, game_index_entries(pokemon_raw, pokemon_id, id_maps.game_version))
  end

  defp ability_entries(pokemon_raw, pokemon_id, ability_map) do
    Transformer.pokemon_abilities_attrs(pokemon_raw)
    |> Enum.map(fn attrs ->
      ability_id = Map.fetch!(ability_map, attrs.ability_name)
      attrs |> Map.delete(:ability_name) |> Map.merge(%{pokemon_id: pokemon_id, ability_id: ability_id})
    end)
  end

  defp type_entries(pokemon_raw, pokemon_id, type_map) do
    Transformer.pokemon_types_attrs(pokemon_raw)
    |> Enum.map(fn attrs ->
      type_id = Map.fetch!(type_map, attrs.type_name)
      attrs |> Map.delete(:type_name) |> Map.merge(%{pokemon_id: pokemon_id, type_id: type_id})
    end)
  end

  defp stat_entries(pokemon_raw, pokemon_id, stat_map) do
    Transformer.pokemon_stats_attrs(pokemon_raw)
    |> Enum.map(fn attrs ->
      stat_id = Map.fetch!(stat_map, attrs.stat_name)
      attrs |> Map.delete(:stat_name) |> Map.merge(%{pokemon_id: pokemon_id, stat_id: stat_id})
    end)
  end

  defp move_entries(pokemon_raw, pokemon_id, move_map) do
    Transformer.pokemon_moves_attrs(pokemon_raw)
    |> Enum.map(fn attrs ->
      move_id = Map.fetch!(move_map, attrs.move_name)
      attrs |> Map.delete(:move_name) |> Map.merge(%{pokemon_id: pokemon_id, move_id: move_id})
    end)
  end

  defp sprite_entry(pokemon_raw, pokemon_id) do
    Transformer.sprite_attrs(pokemon_raw) |> Map.put(:pokemon_id, pokemon_id)
  end

  defp game_index_entries(pokemon_raw, pokemon_id, game_version_map) do
    pokemon_raw["game_indices"]
    |> Enum.flat_map(fn gi ->
      case Map.get(game_version_map, gi["version"]["name"]) do
        nil -> []
        game_version_id -> [%{pokemon_id: pokemon_id, game_version_id: game_version_id, game_index: gi["game_index"]}]
      end
    end)
  end

  # ---------------------------------------------------------------------------
  # Loading

  defp load_pokemon(pokemon_id) do
    pokemon =
      Pokemon
      |> where([p], p.id == ^pokemon_id)
      |> preload(^Pokemon.full_preloads())
      |> Repo.one()
      |> Pokemon.populate_virtual_fields()

    {:ok, pokemon}
  end

  # ---------------------------------------------------------------------------
  # Helpers

  defp insert_all_idempotent(_schema, []), do: :ok

  defp insert_all_idempotent(schema, entries) do
    now = DateTime.utc_now() |> DateTime.truncate(:microsecond)
    entries_with_timestamps = Enum.map(entries, &Map.merge(&1, %{inserted_at: now, updated_at: now}))
    Repo.insert_all(schema, entries_with_timestamps, on_conflict: :nothing)
    :ok
  end
end
