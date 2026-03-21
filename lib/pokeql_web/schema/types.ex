defmodule PokeqlWeb.Schema.Types do
  @moduledoc "Absinthe type definitions for Pokemon GraphQL API."

  use Absinthe.Schema.Notation

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
    field :moves, list_of(:move)
  end
end
