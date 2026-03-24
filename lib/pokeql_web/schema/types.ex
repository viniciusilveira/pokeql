defmodule PokeqlWeb.Schema.Types do
  @moduledoc "Absinthe type definitions for Pokemon GraphQL API."

  use Absinthe.Schema.Notation

  alias Pokeql.PokemonContext

  @desc "Taxonomic and biological classification data for a Pokemon species."
  object :species do
    @desc "Unique species identifier."
    field :id, :id
    @desc "Species name, e.g. `bulbasaur`."
    field :name, :string
    @desc "Generation in which this species was introduced, e.g. `generation-i`."
    field :generation_name, :string
    @desc "Predominant body colour, e.g. `green`."
    field :color_name, :string
    @desc "Body shape category, e.g. `quadruped`."
    field :shape_name, :string
    @desc "Natural habitat, e.g. `grassland`."
    field :habitat_name, :string
    @desc "How quickly this species gains experience levels, e.g. `medium-slow`."
    field :growth_rate_name, :string
    @desc "Chance of being female in eighths (-1 means genderless)."
    field :gender_rate, :integer
    @desc "Likelihood of capture (0–255; higher is easier)."
    field :capture_rate, :integer
    @desc "Starting happiness value when obtained."
    field :base_happiness, :integer
    @desc "Whether this is a baby Pokemon."
    field :is_baby, :boolean
    @desc "Initial number of steps needed to hatch the egg."
    field :hatch_counter, :integer
    @desc "Whether males and females have visible sprite differences."
    field :has_gender_differences, :boolean
    @desc "Whether this species is legendary."
    field :is_legendary, :boolean
    @desc "Whether this species is mythical."
    field :is_mythical, :boolean
  end

  @desc "A passive power that a Pokemon can have."
  object :ability do
    @desc "Unique ability identifier."
    field :id, :id
    @desc "Ability name, e.g. `overgrow`."
    field :name, :string
    @desc "Generation in which this ability was introduced."
    field :generation_name, :string
    @desc "Whether this ability appears in the main series games."
    field :is_main_series, :boolean
    @desc "Brief description of what the ability does."
    field :short_effect, :string
  end

  @desc "An elemental type that affects battle damage calculation."
  object :pokemon_type do
    @desc "Unique type identifier."
    field :id, :id
    @desc "Type name, e.g. `fire`."
    field :name, :string
    @desc "Generation in which this type was introduced."
    field :generation_name, :string
    @desc "Damage class (physical, special, or status)."
    field :damage_class_name, :string
  end

  @desc "A numerical attribute that governs a Pokemon's capabilities in battle."
  object :stat do
    @desc "Unique stat identifier."
    field :id, :id
    @desc "Stat name, e.g. `attack`."
    field :name, :string
    @desc "Numeric index used internally by the games."
    field :game_index, :integer
    @desc "Whether this stat only applies during battle."
    field :is_battle_only, :boolean
  end

  @desc "A Pokemon's base value and effort yield for a specific stat."
  object :pokemon_stat do
    @desc "Base stat value for this Pokemon."
    field :base_stat, :integer
    @desc "Effort value (EV) this Pokemon yields when defeated."
    field :effort, :integer
    @desc "The stat this entry describes."
    field :stat, :stat
  end

  @desc "A battle move that a Pokemon can learn and use."
  object :move do
    @desc "Unique move identifier."
    field :id, :id
    @desc "Move name, e.g. `tackle`."
    field :name, :string
    @desc "Generation in which this move was introduced."
    field :generation_name, :string
    @desc "Base power of the move (null for non-damaging moves)."
    field :power, :integer
    @desc "Power points — maximum number of times the move can be used."
    field :pp, :integer
    @desc "Percentage chance the move will hit (null for moves that bypass accuracy checks)."
    field :accuracy, :integer
    @desc "Determines order within a turn (higher acts first)."
    field :priority, :integer
    @desc "Elemental type of the move, e.g. `normal`."
    field :type_name, :string
    @desc "Whether the move is physical, special, or a status move."
    field :damage_class_name, :string
    @desc "Brief description of what the move does."
    field :short_effect, :string
  end

  @desc "A paired set of game versions released together, e.g. Red/Blue."
  object :version_group do
    @desc "Unique version group identifier."
    field :id, :id
    @desc "Version group name, e.g. `red-blue`."
    field :name, :string
    @desc "Generation this version group belongs to."
    field :generation_name, :string
    @desc "Chronological ordering index."
    field :sort_order, :integer
  end

  @desc "A specific game release within a version group, e.g. Pokemon Red."
  object :game_version do
    @desc "Unique game version identifier."
    field :id, :id
    @desc "Game version name, e.g. `red`."
    field :name, :string
    @desc "The version group this game belongs to."
    field :version_group_name, :string
  end

  @desc "Details about how and when a Pokemon learns a specific move in a given version group."
  object :pokemon_move_detail do
    @desc "Level at which the move is learned (0 for non level-up methods)."
    field :level_learned_at, :integer
    @desc "How the move is learned, e.g. `level-up`, `machine`, `egg`."
    field :learn_method, :string

    @desc "The move being learned."
    field :move, :move do
      resolve(fn detail, _, _ -> {:ok, detail.pokemon_move.move} end)
    end

    @desc "The game version group this learning detail applies to."
    field :version_group, :version_group do
      resolve(fn detail, _, _ -> {:ok, detail.version_group} end)
    end
  end

  @desc "Image URLs for a Pokemon's official game sprites."
  object :sprite do
    @desc "Unique sprite record identifier."
    field :id, :id
    @desc "Default front-facing sprite URL."
    field :front_default, :string
    @desc "Shiny front-facing sprite URL."
    field :front_shiny, :string
    @desc "Default back-facing sprite URL."
    field :back_default, :string
    @desc "Shiny back-facing sprite URL."
    field :back_shiny, :string
    @desc "Female front-facing sprite URL (null if no gender difference)."
    field :front_female, :string
    @desc "Female back-facing sprite URL (null if no gender difference)."
    field :back_female, :string
    @desc "Shiny female front-facing sprite URL."
    field :front_shiny_female, :string
    @desc "Shiny female back-facing sprite URL."
    field :back_shiny_female, :string
  end

  @desc "A Pokemon — a catchable creature with stats, types, abilities, and learnable moves."
  object :pokemon do
    @desc "National Pokedex number."
    field :id, :id
    @desc "Pokemon name, e.g. `pikachu`."
    field :name, :string
    @desc "Height in decimetres."
    field :height, :integer
    @desc "Weight in hectograms."
    field :weight, :integer
    @desc "Sort order for display purposes (species-level ordering)."
    field :order, :integer
    @desc "Whether this is the default form of the species."
    field :is_default, :boolean
    @desc "Base experience points gained by the opponent when this Pokemon is defeated."
    field :base_experience, :integer
    @desc "Sum of all base stats — a quick power indicator."
    field :total_base_stats, :integer
    @desc "List of elemental type names this Pokemon has, e.g. `[\"grass\", \"poison\"]`."
    field :type_names, list_of(:string)
    @desc "List of ability names this Pokemon can have."
    field :ability_names, list_of(:string)
    @desc "Species classification and biological metadata."
    field :species, :species
    @desc "Elemental types with full type details."
    field :types, list_of(:pokemon_type)
    @desc "Full ability objects including descriptions."
    field :abilities, list_of(:ability)

    @desc "Base stats and EV yields for each stat."
    field :stats, list_of(:pokemon_stat) do
      resolve(fn pokemon, _, _ -> {:ok, pokemon.pokemon_stats} end)
    end

    @desc "Sprite image URLs for this Pokemon."
    field :sprites, :sprite

    @desc "Moves this Pokemon can learn. Filter by `versionGroup` to get learn method and level details."
    field :moves, list_of(:pokemon_move_detail) do
      @desc "Filter moves to a specific version group, e.g. `red-blue`. Omit to return all learnable moves without version detail."
      arg(:version_group, :string)

      resolve(fn pokemon, args, _ ->
        case Map.get(args, :version_group) do
          nil ->
            flat =
              Enum.map(pokemon.moves, fn m ->
                %{
                  pokemon_move: %{move: m},
                  version_group: nil,
                  level_learned_at: nil,
                  learn_method: nil
                }
              end)

            {:ok, flat}

          vg_name ->
            {:ok, PokemonContext.get_pokemon_moves_by_version_group(pokemon.id, vg_name)}
        end
      end)
    end
  end
end
