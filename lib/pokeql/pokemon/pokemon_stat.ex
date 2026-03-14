defmodule Pokeql.Pokemon.PokemonStat do
  @moduledoc """
  Ecto schema for the junction table between Pokemon and Stats.

  This schema represents the relationship between a Pokemon and its stats,
  including the base stat value (1-255) and effort value (0-3) for each stat.
  Each Pokemon has exactly 6 core stats: HP, Attack, Defense, Special Attack,
  Special Defense, and Speed.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          pokemon_id: integer(),
          stat_id: integer(),
          base_stat: integer(),
          effort: integer(),
          pokemon: Pokeql.Pokemon.t() | Ecto.Association.NotLoaded.t(),
          stat: Pokeql.Pokemon.Stat.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "pokemon_stats" do
    field :base_stat, :integer
    field :effort, :integer

    belongs_to :pokemon, Pokeql.Pokemon
    belongs_to :stat, Pokeql.Pokemon.Stat

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Creates a changeset for pokemon stat data.

  ## Parameters
  - `pokemon_stat` - The pokemon stat struct (or %PokemonStat{} for new records)
  - `attrs` - The attributes to change

  ## Examples

      iex> changeset = PokemonStat.changeset(%PokemonStat{}, %{
      ...>   pokemon_id: 1,
      ...>   stat_id: 1,
      ...>   base_stat: 45,
      ...>   effort: 0
      ...> })
      iex> changeset.valid?
      true

      iex> changeset = PokemonStat.changeset(%PokemonStat{}, %{base_stat: 300})
      iex> changeset.valid?
      false

  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(pokemon_stat, attrs) do
    pokemon_stat
    |> cast(attrs, [:pokemon_id, :stat_id, :base_stat, :effort])
    |> validate_required([:pokemon_id, :stat_id, :base_stat, :effort])
    |> validate_number(:base_stat,
         greater_than_or_equal_to: 1,
         less_than_or_equal_to: 255,
         message: "must be between 1 and 255")
    |> validate_number(:effort,
         greater_than_or_equal_to: 0,
         less_than_or_equal_to: 3,
         message: "must be between 0 and 3")
    |> unique_constraint([:pokemon_id, :stat_id],
         name: :pokemon_stats_pokemon_id_stat_id_index)
    |> foreign_key_constraint(:pokemon_id)
    |> foreign_key_constraint(:stat_id)
  end

  @doc """
  Returns the valid range for base stat values.
  """
  @spec valid_base_stat_range() :: Range.t()
  def valid_base_stat_range, do: 1..255

  @doc """
  Returns the valid range for effort values (EVs).
  """
  @spec valid_effort_range() :: Range.t()
  def valid_effort_range, do: 0..3

  @doc """
  Calculates the total base stats for a list of Pokemon stats.

  ## Examples

      iex> stats = [
      ...>   %PokemonStat{base_stat: 45},
      ...>   %PokemonStat{base_stat: 49},
      ...>   %PokemonStat{base_stat: 49},
      ...>   %PokemonStat{base_stat: 65},
      ...>   %PokemonStat{base_stat: 65},
      ...>   %PokemonStat{base_stat: 45}
      ...> ]
      iex> PokemonStat.total_base_stats(stats)
      318

  """
  @spec total_base_stats([t()]) :: integer()
  def total_base_stats(pokemon_stats) when is_list(pokemon_stats) do
    pokemon_stats
    |> Enum.map(& &1.base_stat)
    |> Enum.sum()
  end

  @doc """
  Calculates the total effort values for a list of Pokemon stats.

  ## Examples

      iex> stats = [
      ...>   %PokemonStat{effort: 0},
      ...>   %PokemonStat{effort: 0},
      ...>   %PokemonStat{effort: 0},
      ...>   %PokemonStat{effort: 1},
      ...>   %PokemonStat{effort: 0},
      ...>   %PokemonStat{effort: 0}
      ...> ]
      iex> PokemonStat.total_effort_values(stats)
      1

  """
  @spec total_effort_values([t()]) :: integer()
  def total_effort_values(pokemon_stats) when is_list(pokemon_stats) do
    pokemon_stats
    |> Enum.map(& &1.effort)
    |> Enum.sum()
  end

  @doc """
  Validates that a Pokemon has exactly 6 stats (the core stats).
  """
  @spec valid_stat_count?([t()]) :: boolean()
  def valid_stat_count?(pokemon_stats) when is_list(pokemon_stats) do
    length(pokemon_stats) == 6
  end
end
