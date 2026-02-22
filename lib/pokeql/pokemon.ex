defmodule Pokeql.Pokemon do
  @moduledoc """
  Ecto schema for individual Pokemon.

  Pokemon represent specific creatures in the Pokemon universe.
  Each Pokemon belongs to a species and has individual characteristics
  such as height, weight, base experience, and various relationships
  to types, abilities, moves, and stats.

  This schema serves as the central hub connecting all Pokemon-related
  data through junction tables and direct relationships.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          height: integer(),
          weight: integer(),
          base_experience: integer() | nil,
          order: integer(),
          is_default: boolean(),
          species_id: integer(),
          species: Pokeql.Pokemon.Species.t() | Ecto.Association.NotLoaded.t(),
          pokemon_abilities: [Pokeql.Pokemon.PokemonAbility.t()] | Ecto.Association.NotLoaded.t(),
          abilities: [Pokeql.Pokemon.Ability.t()] | Ecto.Association.NotLoaded.t(),
          pokemon_types: [Pokeql.Pokemon.PokemonType.t()] | Ecto.Association.NotLoaded.t(),
          types: [Pokeql.Pokemon.Type.t()] | Ecto.Association.NotLoaded.t(),
          pokemon_stats: [Pokeql.Pokemon.PokemonStat.t()] | Ecto.Association.NotLoaded.t(),
          pokemon_moves: [Pokeql.Pokemon.PokemonMove.t()] | Ecto.Association.NotLoaded.t(),
          moves: [Pokeql.Pokemon.Move.t()] | Ecto.Association.NotLoaded.t(),
          sprites: Pokeql.Pokemon.Sprite.t() | Ecto.Association.NotLoaded.t() | nil,
          pokemon_game_indices: [Pokeql.Pokemon.PokemonGameIndex.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "pokemons" do
    field :name, :string
    field :height, :integer
    field :weight, :integer
    field :base_experience, :integer
    field :order, :integer
    field :is_default, :boolean, default: false

    # Virtual fields for computed data
    field :total_base_stats, :integer, virtual: true
    field :type_names, {:array, :string}, virtual: true
    field :ability_names, {:array, :string}, virtual: true
    field :height_meters, :float, virtual: true  # height in meters
    field :weight_kg, :float, virtual: true      # weight in kg

    # Primary relationship
    belongs_to :species, Pokeql.Pokemon.Species

    # Junction table relationships with additional fields
    has_many :pokemon_abilities, Pokeql.Pokemon.PokemonAbility
    has_many :abilities, through: [:pokemon_abilities, :ability]

    has_many :pokemon_types, Pokeql.Pokemon.PokemonType
    has_many :types, through: [:pokemon_types, :type]

    has_many :pokemon_stats, Pokeql.Pokemon.PokemonStat
    # Note: No direct has_many through for stats since we need base_stat values

    has_many :pokemon_moves, Pokeql.Pokemon.PokemonMove
    has_many :moves, through: [:pokemon_moves, :move]

    # Direct relationships
    has_one :sprites, Pokeql.Pokemon.Sprite
    has_many :pokemon_game_indices, Pokeql.Pokemon.PokemonGameIndex

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Creates a changeset for Pokemon data.

  ## Parameters
  - `pokemon` - The Pokemon struct (or %Pokemon{} for new records)
  - `attrs` - The attributes to change

  ## Examples

      iex> changeset = Pokemon.changeset(%Pokemon{}, %{
      ...>   name: "bulbasaur",
      ...>   height: 7,
      ...>   weight: 69,
      ...>   base_experience: 64,
      ...>   order: 1,
      ...>   species_id: 1
      ...> })
      iex> changeset.valid?
      true

      iex> changeset = Pokemon.changeset(%Pokemon{}, %{height: 0})
      iex> changeset.valid?
      false

  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(pokemon, attrs) do
    pokemon
    |> cast(attrs, [
      :name,
      :height,
      :weight,
      :base_experience,
      :order,
      :is_default,
      :species_id
    ])
    |> validate_required([:name, :height, :weight, :order, :species_id])
    |> validate_length(:name, min: 1, max: 100)
    |> validate_format(:name, ~r/^[a-z0-9\-]+$/, message: "must be lowercase with hyphens")
    |> validate_number(:height, greater_than: 0, message: "must be positive (in decimeters)")
    |> validate_number(:weight, greater_than: 0, message: "must be positive (in hectograms)")
    |> validate_number(:base_experience, greater_than_or_equal_to: 0, message: "must be non-negative")
    |> validate_number(:order, greater_than_or_equal_to: 0)
    |> validate_species_exists()
    |> unique_constraint(:name)
    |> foreign_key_constraint(:species_id)
  end

  @doc """
  Creates a changeset specifically for creating Pokemon with computed virtual fields.
  """
  @spec changeset_with_virtuals(t(), map()) :: Ecto.Changeset.t()
  def changeset_with_virtuals(pokemon, attrs) do
    pokemon
    |> changeset(attrs)
    |> put_virtual_fields()
  end

  # Private functions

  defp validate_species_exists(changeset) do
    # This validation will be enhanced when the context is implemented
    changeset
  end

  defp put_virtual_fields(changeset) do
    changeset
    |> put_height_meters()
    |> put_weight_kg()
    # Note: total_base_stats, type_names, ability_names will be set when loading with associations
  end

  defp put_height_meters(changeset) do
    case get_field(changeset, :height) do
      nil -> changeset
      height -> put_change(changeset, :height_meters, height / 10.0)
    end
  end

  defp put_weight_kg(changeset) do
    case get_field(changeset, :weight) do
      nil -> changeset
      weight -> put_change(changeset, :weight_kg, weight / 10.0)
    end
  end

  @doc """
  Calculates total base stats for a Pokemon when pokemon_stats are preloaded.

  ## Examples

      iex> pokemon = %Pokemon{pokemon_stats: [
      ...>   %PokemonStat{base_stat: 45},
      ...>   %PokemonStat{base_stat: 49},
      ...>   %PokemonStat{base_stat: 49},
      ...>   %PokemonStat{base_stat: 65},
      ...>   %PokemonStat{base_stat: 65},
      ...>   %PokemonStat{base_stat: 45}
      ...> ]}
      iex> Pokemon.calculate_total_base_stats(pokemon)
      318

  """
  @spec calculate_total_base_stats(t()) :: integer() | nil
  def calculate_total_base_stats(%__MODULE__{pokemon_stats: %Ecto.Association.NotLoaded{}}), do: nil
  def calculate_total_base_stats(%__MODULE__{pokemon_stats: pokemon_stats}) do
    pokemon_stats
    |> Enum.map(& &1.base_stat)
    |> Enum.sum()
  end

  @doc """
  Extracts type names when types are preloaded.

  ## Examples

      iex> pokemon = %Pokemon{types: [
      ...>   %Type{name: "grass"},
      ...>   %Type{name: "poison"}
      ...> ]}
      iex> Pokemon.extract_type_names(pokemon)
      ["grass", "poison"]

  """
  @spec extract_type_names(t()) :: [String.t()] | []
  def extract_type_names(%__MODULE__{types: %Ecto.Association.NotLoaded{}}), do: []
  def extract_type_names(%__MODULE__{types: types}) do
    Enum.map(types, & &1.name)
  end

  @doc """
  Extracts ability names when abilities are preloaded.

  ## Examples

      iex> pokemon = %Pokemon{abilities: [
      ...>   %Ability{name: "overgrow"},
      ...>   %Ability{name: "chlorophyll"}
      ...> ]}
      iex> Pokemon.extract_ability_names(pokemon)
      ["overgrow", "chlorophyll"]

  """
  @spec extract_ability_names(t()) :: [String.t()] | []
  def extract_ability_names(%__MODULE__{abilities: %Ecto.Association.NotLoaded{}}), do: []
  def extract_ability_names(%__MODULE__{abilities: abilities}) do
    Enum.map(abilities, & &1.name)
  end

  @doc """
  Populates virtual fields when associations are preloaded.
  """
  @spec populate_virtual_fields(t()) :: t()
  def populate_virtual_fields(%__MODULE__{} = pokemon) do
    pokemon
    |> Map.put(:total_base_stats, calculate_total_base_stats(pokemon))
    |> Map.put(:type_names, extract_type_names(pokemon))
    |> Map.put(:ability_names, extract_ability_names(pokemon))
    |> Map.put(:height_meters, pokemon.height / 10.0)
    |> Map.put(:weight_kg, pokemon.weight / 10.0)
  end

  @doc """
  Returns queries to efficiently preload base Pokemon data (types and species).
  """
  @spec base_preloads() :: [atom()]
  def base_preloads do
    [:species, :types]
  end

  @doc """
  Returns queries to preload Pokemon battle data (stats, abilities, moves).
  """
  @spec battle_preloads() :: [atom()]
  def battle_preloads do
    [:pokemon_stats, :abilities, :moves]
  end

  @doc """
  Returns queries to preload all Pokemon relationships.
  """
  @spec full_preloads() :: [atom()]
  def full_preloads do
    [
      :species,
      :pokemon_abilities,
      :abilities,
      :pokemon_types,
      :types,
      :pokemon_stats,
      :pokemon_moves,
      :moves,
      :sprites,
      :pokemon_game_indices
    ]
  end

  @doc """
  Validates that a Pokemon has the correct number of types (1-2).
  Used in junction table validations.
  """
  @spec valid_type_count?([Pokeql.Pokemon.PokemonType.t()]) :: boolean()
  def valid_type_count?(pokemon_types) when is_list(pokemon_types) do
    length(pokemon_types) in [1, 2]
  end

  @doc """
  Validates that a Pokemon has exactly 6 core stats.
  Used in stat validation logic.
  """
  @spec valid_stat_count?([Pokeql.Pokemon.PokemonStat.t()]) :: boolean()
  def valid_stat_count?(pokemon_stats) when is_list(pokemon_stats) do
    length(pokemon_stats) == 6
  end
end
