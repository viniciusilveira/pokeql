defmodule PokeqlWeb.Schema.Types do
  @moduledoc "Absinthe type definitions for Pokemon GraphQL API."

  use Absinthe.Schema.Notation

  alias Pokeql.PokemonContext

  object :species do
    field :id, :id
    field :name, :string
    field :generation_name, :string
    field :color_name, :string
    field :shape_name, :string
    field :habitat_name, :string
    field :growth_rate_name, :string
    field :gender_rate, :integer
    field :capture_rate, :integer
    field :base_happiness, :integer
    field :is_baby, :boolean
    field :hatch_counter, :integer
    field :has_gender_differences, :boolean
    field :is_legendary, :boolean
    field :is_mythical, :boolean
  end

  object :ability do
    field :id, :id
    field :name, :string
    field :generation_name, :string
    field :is_main_series, :boolean
    field :short_effect, :string
  end

  object :pokemon_type do
    field :id, :id
    field :name, :string
    field :generation_name, :string
    field :damage_class_name, :string
  end

  object :stat do
    field :id, :id
    field :name, :string
    field :game_index, :integer
    field :is_battle_only, :boolean
  end

  object :pokemon_stat do
    field :base_stat, :integer
    field :effort, :integer
    field :stat, :stat
  end

  object :move do
    field :id, :id
    field :name, :string
    field :generation_name, :string
    field :power, :integer
    field :pp, :integer
    field :accuracy, :integer
    field :priority, :integer
    field :type_name, :string
    field :damage_class_name, :string
    field :short_effect, :string
  end

  object :version_group do
    field :id, :id
    field :name, :string
    field :generation_name, :string
    field :sort_order, :integer
  end

  object :game_version do
    field :id, :id
    field :name, :string
    field :version_group_name, :string
  end

  object :pokemon_move_detail do
    field :level_learned_at, :integer
    field :learn_method, :string

    field :move, :move do
      resolve(fn detail, _, _ -> {:ok, detail.pokemon_move.move} end)
    end

    field :version_group, :version_group do
      resolve(fn detail, _, _ -> {:ok, detail.version_group} end)
    end
  end

  object :sprite do
    field :id, :id
    field :front_default, :string
    field :front_shiny, :string
    field :back_default, :string
    field :back_shiny, :string
    field :front_female, :string
    field :back_female, :string
    field :front_shiny_female, :string
    field :back_shiny_female, :string
  end

  object :pokemon do
    field :id, :id
    field :name, :string
    field :height, :integer
    field :weight, :integer
    field :order, :integer
    field :is_default, :boolean
    field :base_experience, :integer
    field :total_base_stats, :integer
    field :type_names, list_of(:string)
    field :ability_names, list_of(:string)
    field :species, :species
    field :types, list_of(:pokemon_type)
    field :abilities, list_of(:ability)

    field :stats, list_of(:pokemon_stat) do
      resolve(fn pokemon, _, _ -> {:ok, pokemon.pokemon_stats} end)
    end

    field :sprites, :sprite

    field :moves, list_of(:pokemon_move_detail) do
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
