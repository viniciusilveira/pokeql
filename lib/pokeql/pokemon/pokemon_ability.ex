defmodule Pokeql.Pokemon.PokemonAbility do
  @moduledoc """
  Ecto schema for the junction table between Pokemon and Abilities.

  This schema represents the relationship between a Pokemon and its abilities,
  including the slot position (1-3) and whether the ability is hidden.
  Each Pokemon can have 1-3 abilities, with at most one hidden ability.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          pokemon_id: integer(),
          ability_id: integer(),
          slot: integer(),
          is_hidden: boolean(),
          pokemon: Pokeql.Pokemon.t() | Ecto.Association.NotLoaded.t(),
          ability: Pokeql.Pokemon.Ability.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "pokemon_abilities" do
    field :slot, :integer
    field :is_hidden, :boolean, default: false

    belongs_to :pokemon, Pokeql.Pokemon
    belongs_to :ability, Pokeql.Pokemon.Ability

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Creates a changeset for pokemon ability data.

  ## Parameters
  - `pokemon_ability` - The pokemon ability struct (or %PokemonAbility{} for new records)
  - `attrs` - The attributes to change

  ## Examples

      iex> changeset = PokemonAbility.changeset(%PokemonAbility{}, %{
      ...>   pokemon_id: 1,
      ...>   ability_id: 1,
      ...>   slot: 1,
      ...>   is_hidden: false
      ...> })
      iex> changeset.valid?
      true

      iex> changeset = PokemonAbility.changeset(%PokemonAbility{}, %{slot: 4})
      iex> changeset.valid?
      false

  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(pokemon_ability, attrs) do
    pokemon_ability
    |> cast(attrs, [:pokemon_id, :ability_id, :slot, :is_hidden])
    |> validate_required([:pokemon_id, :ability_id, :slot])
    |> validate_inclusion(:slot, 1..3, message: "must be between 1 and 3")
    |> validate_hidden_ability_logic()
    |> unique_constraint([:pokemon_id, :slot], name: :pokemon_abilities_pokemon_id_slot_index)
    |> foreign_key_constraint(:pokemon_id)
    |> foreign_key_constraint(:ability_id)
  end

  # Private validation functions

  defp validate_hidden_ability_logic(changeset) do
    case {get_field(changeset, :slot), get_field(changeset, :is_hidden)} do
      {3, false} ->
        add_error(changeset, :is_hidden, "slot 3 abilities must be hidden")
      {slot, true} when slot in [1, 2] ->
        add_error(changeset, :is_hidden, "only slot 3 abilities can be hidden")
      _ ->
        changeset
    end
  end

  @doc """
  Returns the valid slot numbers for Pokemon abilities.
  """
  @spec valid_slots() :: [integer()]
  def valid_slots, do: [1, 2, 3]

  @doc """
  Checks if an ability slot can be hidden.
  Typically, only slot 3 abilities can be hidden, but this can vary.
  """
  @spec can_be_hidden?(integer()) :: boolean()
  def can_be_hidden?(slot) when slot in 1..3, do: true
  def can_be_hidden?(_), do: false
end
