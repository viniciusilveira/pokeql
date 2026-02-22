defmodule Pokeql.Pokemon.GameVersion do
  @moduledoc """
  Ecto schema for Pokemon game versions.

  Game versions represent individual Pokemon games within version groups.
  Examples include "red", "blue", "gold", "silver", "diamond", "pearl", etc.
  Multiple game versions can belong to the same version group.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          version_group_name: String.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "game_versions" do
    field :name, :string
    field :version_group_name, :string

    # Relationships
    # Note: belongs_to association to VersionGroup will be set up after all schemas are complete
    has_many :pokemon_game_indices, Pokeql.Pokemon.PokemonGameIndex

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Creates a changeset for game version data.

  ## Parameters
  - `game_version` - The game version struct (or %GameVersion{} for new records)
  - `attrs` - The attributes to change

  ## Examples

      iex> changeset = GameVersion.changeset(%GameVersion{}, %{name: "red", version_group_name: "red-blue"})
      iex> changeset.valid?
      true

      iex> changeset = GameVersion.changeset(%GameVersion{}, %{name: ""})
      iex> changeset.valid?
      false

  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(game_version, attrs) do
    game_version
    |> cast(attrs, [:name, :version_group_name])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 50)
    |> validate_format(:name, ~r/^[a-z0-9\-]+$/, message: "must be lowercase with hyphens")
    |> validate_known_game_version()
    |> unique_constraint(:name)
  end

  # Private validation function
  defp validate_known_game_version(changeset) do
    case get_change(changeset, :name) do
      nil -> changeset
      name ->
        if name in known_game_versions() do
          changeset
        else
          add_error(changeset, :name, "must be a known Pokemon game version")
        end
    end
  end

  @doc """
  Returns a list of known Pokemon game version names.
  """
  @spec known_game_versions() :: [String.t()]
  def known_game_versions do
    ~w[
      red blue yellow
      gold silver crystal
      ruby sapphire emerald firered leafgreen
      diamond pearl platinum heartgold soulsilver
      black white black-2 white-2
      x y omega-ruby alpha-sapphire
      sun moon ultra-sun ultra-moon
      sword shield brilliant-diamond shining-pearl
      scarlet violet
    ]
  end

  @doc """
  Returns game versions grouped by version group.
  """
  @spec versions_by_group() :: %{String.t() => [String.t()]}
  def versions_by_group do
    %{
      "red-blue" => ~w[red blue],
      "yellow" => ~w[yellow],
      "gold-silver" => ~w[gold silver],
      "crystal" => ~w[crystal],
      "ruby-sapphire" => ~w[ruby sapphire],
      "emerald" => ~w[emerald],
      "firered-leafgreen" => ~w[firered leafgreen],
      "diamond-pearl" => ~w[diamond pearl],
      "platinum" => ~w[platinum],
      "heartgold-soulsilver" => ~w[heartgold soulsilver],
      "black-white" => ~w[black white],
      "black-2-white-2" => ~w[black-2 white-2],
      "x-y" => ~w[x y],
      "omega-ruby-alpha-sapphire" => ~w[omega-ruby alpha-sapphire],
      "sun-moon" => ~w[sun moon],
      "ultra-sun-ultra-moon" => ~w[ultra-sun ultra-moon],
      "sword-shield" => ~w[sword shield],
      "brilliant-diamond-shining-pearl" => ~w[brilliant-diamond shining-pearl],
      "scarlet-violet" => ~w[scarlet violet]
    }
  end
end
