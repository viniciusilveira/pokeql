defmodule Pokeql.Pokemon.Ability do
  @moduledoc """
  Ecto schema for Pokemon abilities.

  Abilities are special traits that Pokemon possess which can affect
  battle mechanics, field effects, or other game interactions.
  Each ability has a name, effect description, and metadata about
  when it was introduced.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          short_effect: String.t() | nil,
          generation_name: String.t(),
          is_main_series: boolean(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "abilities" do
    field :name, :string
    field :short_effect, :string
    field :generation_name, :string
    field :is_main_series, :boolean, default: true

    # Relationships
    has_many :pokemon_abilities, Pokeql.Pokemon.PokemonAbility
    has_many :pokemons, through: [:pokemon_abilities, :pokemon]

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Creates a changeset for ability data.

  ## Parameters
  - `ability` - The ability struct (or %Ability{} for new records)
  - `attrs` - The attributes to change

  ## Examples

      iex> changeset = Ability.changeset(%Ability{}, %{name: "overgrow", generation_name: "generation-iii"})
      iex> changeset.valid?
      true

      iex> changeset = Ability.changeset(%Ability{}, %{name: ""})
      iex> changeset.valid?
      false

  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(ability, attrs) do
    ability
    |> cast(attrs, [:name, :short_effect, :generation_name, :is_main_series])
    |> validate_required([:name, :generation_name])
    |> validate_length(:name, min: 1, max: 100)
    |> validate_length(:short_effect, max: 1000)
    |> validate_format(:name, ~r/^[a-z0-9\-]+$/, message: "must be lowercase with hyphens")
    |> validate_format(:generation_name, ~r/^generation-[ivx]+$/, message: "must be in format 'generation-i/ii/iii/etc'")
    |> unique_constraint(:name)
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
