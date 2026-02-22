defmodule Pokeql.Pokemon.Species do
  @moduledoc """
  Ecto schema for Pokemon species data.

  Species represent the biological classification of Pokemon, containing
  breeding information, legendary status, habitat details, and other
  species-wide characteristics shared across all Pokemon of the same species.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          base_happiness: integer(),
          capture_rate: integer(),
          color_name: String.t() | nil,
          gender_rate: integer(),
          growth_rate_name: String.t() | nil,
          habitat_name: String.t() | nil,
          hatch_counter: integer(),
          is_baby: boolean(),
          is_legendary: boolean(),
          is_mythical: boolean(),
          has_gender_differences: boolean(),
          shape_name: String.t() | nil,
          generation_name: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "species" do
    field :name, :string
    field :base_happiness, :integer, default: 0
    field :capture_rate, :integer, default: 45
    field :color_name, :string
    field :gender_rate, :integer, default: -1
    field :growth_rate_name, :string
    field :habitat_name, :string
    field :hatch_counter, :integer, default: 20
    field :is_baby, :boolean, default: false
    field :is_legendary, :boolean, default: false
    field :is_mythical, :boolean, default: false
    field :has_gender_differences, :boolean, default: false
    field :shape_name, :string
    field :generation_name, :string

    # Relationships
    has_many :pokemons, Pokeql.Pokemon

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Creates a changeset for species data.

  ## Parameters
  - `species` - The species struct (or %Species{} for new records)
  - `attrs` - The attributes to change

  ## Examples

      iex> changeset = Species.changeset(%Species{}, %{name: "bulbasaur", generation_name: "generation-i"})
      iex> changeset.valid?
      true

      iex> changeset = Species.changeset(%Species{}, %{capture_rate: 300})
      iex> changeset.valid?
      false

  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(species, attrs) do
    species
    |> cast(attrs, [
      :name,
      :base_happiness,
      :capture_rate,
      :color_name,
      :gender_rate,
      :growth_rate_name,
      :habitat_name,
      :hatch_counter,
      :is_baby,
      :is_legendary,
      :is_mythical,
      :has_gender_differences,
      :shape_name,
      :generation_name
    ])
    |> validate_required([:name, :generation_name])
    |> validate_length(:name, min: 1, max: 100)
    |> validate_inclusion(:capture_rate, 0..255, message: "must be between 0 and 255")
    |> validate_inclusion(:gender_rate, -1..8, message: "must be between -1 (genderless) and 8")
    |> validate_inclusion(:base_happiness, 0..255, message: "must be between 0 and 255")
    |> validate_inclusion(:hatch_counter, 0..255, message: "must be between 0 and 255")
    |> validate_format(:name, ~r/^[a-z0-9\-]+$/, message: "must be lowercase with hyphens")
    |> validate_format(:generation_name, ~r/^generation-[ivx]+$/, message: "must be in format 'generation-i/ii/iii/etc'")
    |> unique_constraint(:name)
  end

  @doc """
  Returns a list of valid color names for Pokemon species.
  """
  @spec valid_colors() :: [String.t()]
  def valid_colors do
    ~w[
      black blue brown gray green pink purple red white yellow
    ]
  end

  @doc """
  Returns a list of valid growth rate names.
  """
  @spec valid_growth_rates() :: [String.t()]
  def valid_growth_rates do
    ~w[
      slow medium fast medium-slow slow-then-very-fast fast-then-very-slow
    ]
  end

  @doc """
  Returns a list of valid habitat names.
  """
  @spec valid_habitats() :: [String.t()]
  def valid_habitats do
    ~w[
      cave forest grassland mountain rare rough-terrain sea urban waters-edge
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
