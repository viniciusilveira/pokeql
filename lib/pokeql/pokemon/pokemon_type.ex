defmodule Pokeql.Pokemon.PokemonType do
  @moduledoc """
  Ecto schema for the junction table between Pokemon and Types.

  This schema represents the relationship between a Pokemon and its types,
  including the slot position (1 for primary type, 2 for secondary type).
  Each Pokemon has 1-2 types, with slot 1 being the primary type and
  slot 2 being the secondary type for dual-type Pokemon.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          pokemon_id: integer(),
          type_id: integer(),
          slot: integer(),
          pokemon: Pokeql.Pokemon.t() | Ecto.Association.NotLoaded.t(),
          type: Pokeql.Pokemon.Type.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "pokemon_types" do
    field :slot, :integer

    belongs_to :pokemon, Pokeql.Pokemon
    belongs_to :type, Pokeql.Pokemon.Type

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Creates a changeset for pokemon type data.

  ## Parameters
  - `pokemon_type` - The pokemon type struct (or %PokemonType{} for new records)
  - `attrs` - The attributes to change

  ## Examples

      iex> changeset = PokemonType.changeset(%PokemonType{}, %{
      ...>   pokemon_id: 1,
      ...>   type_id: 1,
      ...>   slot: 1
      ...> })
      iex> changeset.valid?
      true

      iex> changeset = PokemonType.changeset(%PokemonType{}, %{slot: 3})
      iex> changeset.valid?
      false

  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(pokemon_type, attrs) do
    pokemon_type
    |> cast(attrs, [:pokemon_id, :type_id, :slot])
    |> validate_required([:pokemon_id, :type_id, :slot])
    |> validate_inclusion(:slot, 1..2, message: "must be 1 (primary) or 2 (secondary)")
    |> unique_constraint([:pokemon_id, :slot], name: :pokemon_types_pokemon_id_slot_index)
    |> unique_constraint([:pokemon_id, :type_id], message: "Pokemon cannot have duplicate types")
    |> foreign_key_constraint(:pokemon_id)
    |> foreign_key_constraint(:type_id)
  end

  @doc """
  Returns the valid slot numbers for Pokemon types.
  """
  @spec valid_slots() :: [integer()]
  def valid_slots, do: [1, 2]

  @doc """
  Returns the primary type slot number.
  """
  @spec primary_slot() :: integer()
  def primary_slot, do: 1

  @doc """
  Returns the secondary type slot number.
  """
  @spec secondary_slot() :: integer()
  def secondary_slot, do: 2

  @doc """
  Checks if a Pokemon type entry represents the primary type.
  """
  @spec primary_type?(t()) :: boolean()
  def primary_type?(%__MODULE__{slot: 1}), do: true
  def primary_type?(%__MODULE__{slot: _}), do: false

  @doc """
  Checks if a Pokemon type entry represents the secondary type.
  """
  @spec secondary_type?(t()) :: boolean()
  def secondary_type?(%__MODULE__{slot: 2}), do: true
  def secondary_type?(%__MODULE__{slot: _}), do: false
end
