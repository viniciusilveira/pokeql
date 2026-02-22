defmodule Pokeql.Pokemon.PokemonMoveVersionDetail do
  @moduledoc """
  Ecto schema for Pokemon move learning details by version group.

  This schema stores version-specific information about how a Pokemon learns
  a particular move, including the level at which it's learned and the method
  (level-up, machine, tutor, egg, etc.) for each game version group.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer(),
          pokemon_move_id: integer(),
          version_group_id: integer(),
          level_learned_at: integer(),
          learn_method: String.t(),
          pokemon_move: Pokeql.Pokemon.PokemonMove.t() | Ecto.Association.NotLoaded.t(),
          version_group: Pokeql.Pokemon.VersionGroup.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "pokemon_move_version_details" do
    field :level_learned_at, :integer
    field :learn_method, :string

    belongs_to :pokemon_move, Pokeql.Pokemon.PokemonMove
    belongs_to :version_group, Pokeql.Pokemon.VersionGroup

    timestamps(type: :utc_datetime_usec)
  end

  @doc """
  Creates a changeset for pokemon move version detail data.

  ## Parameters
  - `detail` - The pokemon move version detail struct (or %PokemonMoveVersionDetail{} for new records)
  - `attrs` - The attributes to change

  ## Examples

      iex> changeset = PokemonMoveVersionDetail.changeset(%PokemonMoveVersionDetail{}, %{
      ...>   pokemon_move_id: 1,
      ...>   version_group_id: 1,
      ...>   level_learned_at: 7,
      ...>   learn_method: "level-up"
      ...> })
      iex> changeset.valid?
      true

      iex> changeset = PokemonMoveVersionDetail.changeset(%PokemonMoveVersionDetail{}, %{level_learned_at: 150})
      iex> changeset.valid?
      false

  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(detail, attrs) do
    detail
    |> cast(attrs, [:pokemon_move_id, :version_group_id, :level_learned_at, :learn_method])
    |> validate_required([:pokemon_move_id, :version_group_id, :level_learned_at, :learn_method])
    |> validate_number(:level_learned_at,
         greater_than_or_equal_to: 0,
         less_than_or_equal_to: 100,
         message: "must be between 0 and 100 (0 for evolution/machine)")
    |> validate_inclusion(:learn_method, valid_learn_methods(),
         message: "must be a valid learn method")
    |> unique_constraint([:pokemon_move_id, :version_group_id],
         name: :pokemon_move_version_details_pokemon_move_id_version_group_id_index)
    |> foreign_key_constraint(:pokemon_move_id)
    |> foreign_key_constraint(:version_group_id)
  end

  @doc """
  Returns the valid learn methods for moves.
  """
  @spec valid_learn_methods() :: [String.t()]
  def valid_learn_methods do
    ~w[
      level-up
      machine
      tutor
      egg
      light-ball-egg
      colosseum-purification
      xd-shadow
      xd-purification
      form-change
      zygarde-cube
    ]
  end

  @doc """
  Returns the valid level range for learning moves.
  """
  @spec valid_level_range() :: Range.t()
  def valid_level_range, do: 0..100

  @doc """
  Checks if a learn method involves leveling up.
  """
  @spec level_up_method?(String.t()) :: boolean()
  def level_up_method?("level-up"), do: true
  def level_up_method?(_), do: false

  @doc """
  Checks if a learn method involves a machine (TM/HM/TR).
  """
  @spec machine_method?(String.t()) :: boolean()
  def machine_method?("machine"), do: true
  def machine_method?(_), do: false

  @doc """
  Checks if a learn method involves breeding.
  """
  @spec breeding_method?(String.t()) :: boolean()
  def breeding_method?(method) when method in ~w[egg light-ball-egg], do: true
  def breeding_method?(_), do: false

  @doc """
  Returns moves learned at level 0 (typically evolution or machine moves).
  """
  @spec evolution_or_machine_level() :: integer()
  def evolution_or_machine_level, do: 0
end
