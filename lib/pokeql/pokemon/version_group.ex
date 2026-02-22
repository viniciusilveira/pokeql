defmodule Pokeql.Pokemon.VersionGroup do
  @moduledoc """
  Ecto schema for Pokemon game version groups.

  Version groups represent collections of Pokemon games that share
  similar gameplay mechanics, Pokemon availability, and move sets.
  Examples include "red-blue", "gold-silver", "diamond-pearl", etc.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          generation_name: String.t(),
          sort_order: integer(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "version_groups" do
    field :name, :string
    field :generation_name, :string
    field :sort_order, :integer

    # Relationships
    # Note: GameVersions relate to this through version_group_name field (string-based association)
    has_many :pokemon_move_version_details, Pokeql.Pokemon.PokemonMoveVersionDetail

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Creates a changeset for version group data.

  ## Parameters
  - `version_group` - The version group struct (or %VersionGroup{} for new records)
  - `attrs` - The attributes to change

  ## Examples

      iex> changeset = VersionGroup.changeset(%VersionGroup{}, %{name: "red-blue", generation_name: "generation-i", sort_order: 1})
      iex> changeset.valid?
      true

      iex> changeset = VersionGroup.changeset(%VersionGroup{}, %{sort_order: 0})
      iex> changeset.valid?
      false

  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(version_group, attrs) do
    version_group
    |> cast(attrs, [:name, :generation_name, :sort_order])
    |> validate_required([:name, :generation_name, :sort_order])
    |> validate_length(:name, min: 1, max: 50)
    |> validate_format(:name, ~r/^[a-z0-9\-]+$/, message: "must be lowercase with hyphens")
    |> validate_format(:generation_name, ~r/^generation-[ivx]+$/, message: "must be in format 'generation-i/ii/iii/etc'")
    |> validate_number(:sort_order, greater_than: 0, message: "must be positive")
    |> unique_constraint(:name)
    |> unique_constraint(:sort_order)
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

  @doc """
  Returns known version group names by generation.
  """
  @spec known_version_groups() :: %{String.t() => [String.t()]}
  def known_version_groups do
    %{
      "generation-i" => ~w[red-blue yellow],
      "generation-ii" => ~w[gold-silver crystal],
      "generation-iii" => ~w[ruby-sapphire emerald firered-leafgreen],
      "generation-iv" => ~w[diamond-pearl platinum heartgold-soulsilver],
      "generation-v" => ~w[black-white black-2-white-2],
      "generation-vi" => ~w[x-y omega-ruby-alpha-sapphire],
      "generation-vii" => ~w[sun-moon ultra-sun-ultra-moon],
      "generation-viii" => ~w[sword-shield brilliant-diamond-shining-pearl],
      "generation-ix" => ~w[scarlet-violet]
    }
  end
end
