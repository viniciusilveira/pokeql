defmodule Pokeql.Pokemon.Stat do
  @moduledoc """
  Ecto schema for Pokemon stats.

  Stats represent the various combat and gameplay statistics
  that Pokemon possess, such as HP, Attack, Defense, Special Attack,
  Special Defense, and Speed. Some stats are battle-only and don't
  appear in standard stat calculations.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          game_index: integer(),
          is_battle_only: boolean(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "stats" do
    field :name, :string
    field :game_index, :integer
    field :is_battle_only, :boolean, default: false

    # Relationships
    has_many :pokemon_stats, Pokeql.Pokemon.PokemonStat
    has_many :pokemons, through: [:pokemon_stats, :pokemon]

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Creates a changeset for stat data.

  ## Parameters
  - `stat` - The stat struct (or %Stat{} for new records)
  - `attrs` - The attributes to change

  ## Examples

      iex> changeset = Stat.changeset(%Stat{}, %{name: "hp", game_index: 1})
      iex> changeset.valid?
      true

      iex> changeset = Stat.changeset(%Stat{}, %{game_index: -1})
      iex> changeset.valid?
      false

  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(stat, attrs) do
    stat
    |> cast(attrs, [:name, :game_index, :is_battle_only])
    |> validate_required([:name, :game_index])
    |> validate_length(:name, min: 1, max: 50)
    |> validate_format(:name, ~r/^[a-z\-]+$/, message: "must be lowercase with hyphens")
    |> validate_inclusion(:name, valid_stat_names(), message: "must be a valid Pokemon stat")
    |> validate_number(:game_index, greater_than_or_equal_to: 0)
    |> unique_constraint(:name)
    |> unique_constraint(:game_index)
  end

  @doc """
  Returns a list of valid Pokemon stat names.
  """
  @spec valid_stat_names() :: [String.t()]
  def valid_stat_names do
    ~w[
      hp attack defense special-attack special-defense speed
      accuracy evasion
    ]
  end

  @doc """
  Returns the six core battle stats.
  """
  @spec core_stats() :: [String.t()]
  def core_stats do
    ~w[hp attack defense special-attack special-defense speed]
  end

  @doc """
  Returns battle-only stats (not used in base stat calculations).
  """
  @spec battle_only_stats() :: [String.t()]
  def battle_only_stats do
    ~w[accuracy evasion]
  end
end
