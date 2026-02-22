defmodule Pokeql.Pokemon.Type do
  @moduledoc """
  Ecto schema for Pokemon types.

  Types represent elemental classifications for Pokemon and moves.
  Each type has specific strengths, weaknesses, and characteristics
  that affect battle interactions and gameplay mechanics.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          generation_name: String.t(),
          damage_class_name: String.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "types" do
    field :name, :string
    field :generation_name, :string
    field :damage_class_name, :string

    # Relationships
    has_many :pokemon_types, Pokeql.Pokemon.PokemonType
    has_many :pokemons, through: [:pokemon_types, :pokemon]
    # Note: Moves relate to this through type_name field (string-based association)

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Creates a changeset for type data.

  ## Parameters
  - `type` - The type struct (or %Type{} for new records)
  - `attrs` - The attributes to change

  ## Examples

      iex> changeset = Type.changeset(%Type{}, %{name: "grass", generation_name: "generation-i"})
      iex> changeset.valid?
      true

      iex> changeset = Type.changeset(%Type{}, %{name: "invalid-type"})
      iex> changeset.valid?
      false

  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(type, attrs) do
    type
    |> cast(attrs, [:name, :generation_name, :damage_class_name])
    |> validate_required([:name, :generation_name])
    |> validate_length(:name, min: 1, max: 50)
    |> validate_format(:name, ~r/^[a-z\-]+$/, message: "must be lowercase with hyphens")
    |> validate_format(:generation_name, ~r/^generation-[ivx]+$/, message: "must be in format 'generation-i/ii/iii/etc'")
    |> validate_inclusion(:name, valid_type_names(), message: "must be a valid Pokemon type")
    |> validate_inclusion(:damage_class_name, valid_damage_classes(), message: "must be a valid damage class")
    |> unique_constraint(:name)
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
  Returns a list of valid damage class names.
  """
  @spec valid_damage_classes() :: [String.t()]
  def valid_damage_classes do
    ~w[physical special status]
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
