defmodule Pokeql.Pokemon.Move do
  @moduledoc """
  Ecto schema for Pokemon moves.

  Moves are attacks and techniques that Pokemon can learn and use
  in battle. Each move has specific battle mechanics including
  power, accuracy, PP (Power Points), priority, and type information.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          accuracy: integer() | nil,
          power: integer() | nil,
          pp: integer() | nil,
          priority: integer(),
          damage_class_name: String.t() | nil,
          type_name: String.t() | nil,
          generation_name: String.t(),
          short_effect: String.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "moves" do
    field :name, :string
    field :accuracy, :integer
    field :power, :integer
    field :pp, :integer
    field :priority, :integer, default: 0
    field :damage_class_name, :string
    field :type_name, :string
    field :generation_name, :string
    field :short_effect, :string

    # Relationships
    # Note: type association will be set up after Type schema is complete
    has_many :pokemon_moves, Pokeql.Pokemon.PokemonMove
    has_many :pokemons, through: [:pokemon_moves, :pokemon]

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Creates a changeset for move data.

  ## Parameters
  - `move` - The move struct (or %Move{} for new records)
  - `attrs` - The attributes to change

  ## Examples

      iex> changeset = Move.changeset(%Move{}, %{name: "tackle", type_name: "normal", generation_name: "generation-i"})
      iex> changeset.valid?
      true

      iex> changeset = Move.changeset(%Move{}, %{accuracy: 150})
      iex> changeset.valid?
      false

  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(move, attrs) do
    move
    |> cast(attrs, [
      :name,
      :accuracy,
      :power,
      :pp,
      :priority,
      :damage_class_name,
      :type_name,
      :generation_name,
      :short_effect
    ])
    |> validate_required([:name, :generation_name])
    |> validate_length(:name, min: 1, max: 100)
    |> validate_length(:short_effect, max: 1000)
    |> validate_format(:name, ~r/^[a-z0-9\-]+$/, message: "must be lowercase with hyphens")
    |> validate_format(:generation_name, ~r/^generation-[ivx]+$/, message: "must be in format 'generation-i/ii/iii/etc'")
    |> validate_accuracy()
    |> validate_power()
    |> validate_pp()
    |> validate_priority()
    |> validate_damage_class()
    |> validate_type_name()
    |> unique_constraint(:name)
  end

  # Private validation functions

  defp validate_accuracy(changeset) do
    changeset
    |> validate_number(:accuracy, greater_than_or_equal_to: 1, less_than_or_equal_to: 100,
         message: "must be between 1 and 100, or nil for moves that always hit")
  end

  defp validate_power(changeset) do
    changeset
    |> validate_number(:power, greater_than_or_equal_to: 0,
         message: "must be non-negative, or nil for non-damaging moves")
  end

  defp validate_pp(changeset) do
    changeset
    |> validate_number(:pp, greater_than: 0,
         message: "must be positive")
  end

  defp validate_priority(changeset) do
    changeset
    |> validate_inclusion(:priority, -8..5,
         message: "must be between -8 and 5")
  end

  defp validate_damage_class(changeset) do
    case get_change(changeset, :damage_class_name) do
      nil -> changeset
      _damage_class ->
        validate_inclusion(changeset, :damage_class_name, valid_damage_classes(),
          message: "must be a valid damage class")
    end
  end

  defp validate_type_name(changeset) do
    case get_change(changeset, :type_name) do
      nil -> changeset
      _type_name ->
        validate_inclusion(changeset, :type_name, valid_type_names(),
          message: "must be a valid Pokemon type")
    end
  end

  @doc """
  Returns a list of valid damage class names.
  """
  @spec valid_damage_classes() :: [String.t()]
  def valid_damage_classes do
    ~w[physical special status]
  end

  @doc """
  Returns a list of valid Pokemon type names.
  """
  @spec valid_type_names() :: [String.t()]
  def valid_type_names do
    ~w[
      normal fire water electric grass ice fighting poison ground
      flying psychic bug rock ghost dragon dark steel fairy
    ]
  end

  @doc """
  Returns a list of valid generation names.
  """
  @spec valid_generations() :: [String.t()]
  def valid_generations do
    ~w[
      generation-i generation-ii generation-iii generation-iv
      generation-v generation-vi generation-vii generation-viii generation-ix
    ]
  end
end
