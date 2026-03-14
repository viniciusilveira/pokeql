defmodule Pokeql.PokeAPIFixtures do
  @moduledoc """
  Fixture data for PokeAPI responses. Used in tests to avoid real HTTP calls.
  All data uses string keys, as returned by Jason.decode/1.
  """

  def generation_i do
    {:ok,
     %{
       "name" => "generation-i",
       "id" => 1,
       "pokemon_species" => [
         %{"name" => "bulbasaur", "url" => "https://pokeapi.co/api/v2/pokemon-species/1/"},
         %{"name" => "ivysaur", "url" => "https://pokeapi.co/api/v2/pokemon-species/2/"}
       ],
       "version_groups" => [
         %{"name" => "red-blue", "url" => "https://pokeapi.co/api/v2/version-group/1/"},
         %{"name" => "yellow", "url" => "https://pokeapi.co/api/v2/version-group/2/"}
       ]
     }}
  end

  def bulbasaur_species do
    {:ok,
     %{
       "name" => "bulbasaur",
       "id" => 1,
       "capture_rate" => 45,
       "base_happiness" => 50,
       "hatch_counter" => 20,
       "gender_rate" => 1,
       "is_baby" => false,
       "is_legendary" => false,
       "is_mythical" => false,
       "has_gender_differences" => false,
       "generation" => %{"name" => "generation-i"},
       "color" => %{"name" => "green"},
       "shape" => %{"name" => "quadruped"},
       "habitat" => %{"name" => "grassland"},
       "growth_rate" => %{"name" => "medium-slow"},
       "varieties" => [
         %{
           "is_default" => true,
           "pokemon" => %{
             "name" => "bulbasaur",
             "url" => "https://pokeapi.co/api/v2/pokemon/1/"
           }
         }
       ]
     }}
  end

  def ivysaur_species do
    {:ok,
     %{
       "name" => "ivysaur",
       "id" => 2,
       "capture_rate" => 45,
       "base_happiness" => 50,
       "hatch_counter" => 20,
       "gender_rate" => 1,
       "is_baby" => false,
       "is_legendary" => false,
       "is_mythical" => false,
       "has_gender_differences" => false,
       "generation" => %{"name" => "generation-i"},
       "color" => %{"name" => "green"},
       "shape" => %{"name" => "quadruped"},
       "habitat" => %{"name" => "grassland"},
       "growth_rate" => %{"name" => "medium-slow"},
       "varieties" => [
         %{
           "is_default" => true,
           "pokemon" => %{
             "name" => "ivysaur",
             "url" => "https://pokeapi.co/api/v2/pokemon/2/"
           }
         }
       ]
     }}
  end

  def bulbasaur_pokemon do
    {:ok,
     %{
       "name" => "bulbasaur",
       "id" => 1,
       "height" => 7,
       "weight" => 69,
       "base_experience" => 64,
       "order" => 1,
       "is_default" => true,
       "abilities" => [
         %{
           "ability" => %{"name" => "overgrow", "url" => "https://pokeapi.co/api/v2/ability/65/"},
           "is_hidden" => false,
           "slot" => 1
         },
         %{
           "ability" => %{
             "name" => "chlorophyll",
             "url" => "https://pokeapi.co/api/v2/ability/34/"
           },
           "is_hidden" => true,
           "slot" => 3
         }
       ],
       "types" => [
         %{
           "slot" => 1,
           "type" => %{"name" => "grass", "url" => "https://pokeapi.co/api/v2/type/12/"}
         },
         %{
           "slot" => 2,
           "type" => %{"name" => "poison", "url" => "https://pokeapi.co/api/v2/type/4/"}
         }
       ],
       "stats" => [
         %{
           "base_stat" => 45,
           "effort" => 0,
           "stat" => %{"name" => "hp", "url" => "https://pokeapi.co/api/v2/stat/1/"}
         },
         %{
           "base_stat" => 49,
           "effort" => 0,
           "stat" => %{"name" => "attack", "url" => "https://pokeapi.co/api/v2/stat/2/"}
         },
         %{
           "base_stat" => 49,
           "effort" => 0,
           "stat" => %{"name" => "defense", "url" => "https://pokeapi.co/api/v2/stat/3/"}
         },
         %{
           "base_stat" => 65,
           "effort" => 1,
           "stat" => %{"name" => "special-attack", "url" => "https://pokeapi.co/api/v2/stat/4/"}
         },
         %{
           "base_stat" => 65,
           "effort" => 0,
           "stat" => %{"name" => "special-defense", "url" => "https://pokeapi.co/api/v2/stat/5/"}
         },
         %{
           "base_stat" => 45,
           "effort" => 0,
           "stat" => %{"name" => "speed", "url" => "https://pokeapi.co/api/v2/stat/6/"}
         }
       ],
       "moves" => [
         %{
           "move" => %{"name" => "tackle", "url" => "https://pokeapi.co/api/v2/move/33/"},
           "version_group_details" => [
             %{
               "level_learned_at" => 1,
               "move_learn_method" => %{
                 "name" => "level-up",
                 "url" => "https://pokeapi.co/api/v2/move-learn-method/1/"
               },
               "version_group" => %{
                 "name" => "red-blue",
                 "url" => "https://pokeapi.co/api/v2/version-group/1/"
               }
             }
           ]
         }
       ],
       "sprites" => %{
         "front_default" =>
           "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png",
         "back_default" =>
           "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/1.png",
         "front_shiny" =>
           "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png",
         "back_shiny" =>
           "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/1.png",
         "front_female" => nil,
         "back_female" => nil,
         "front_shiny_female" => nil,
         "back_shiny_female" => nil
       },
       "game_indices" => [
         %{
           "game_index" => 1,
           "version" => %{"name" => "red", "url" => "https://pokeapi.co/api/v2/version/1/"}
         },
         %{
           "game_index" => 1,
           "version" => %{"name" => "blue", "url" => "https://pokeapi.co/api/v2/version/2/"}
         }
       ]
     }}
  end

  def ivysaur_pokemon do
    {:ok,
     %{
       "name" => "ivysaur",
       "id" => 2,
       "height" => 10,
       "weight" => 130,
       "base_experience" => 142,
       "order" => 2,
       "is_default" => true,
       "abilities" => [
         %{
           "ability" => %{"name" => "overgrow", "url" => "https://pokeapi.co/api/v2/ability/65/"},
           "is_hidden" => false,
           "slot" => 1
         },
         %{
           "ability" => %{
             "name" => "chlorophyll",
             "url" => "https://pokeapi.co/api/v2/ability/34/"
           },
           "is_hidden" => true,
           "slot" => 3
         }
       ],
       "types" => [
         %{
           "slot" => 1,
           "type" => %{"name" => "grass", "url" => "https://pokeapi.co/api/v2/type/12/"}
         },
         %{
           "slot" => 2,
           "type" => %{"name" => "poison", "url" => "https://pokeapi.co/api/v2/type/4/"}
         }
       ],
       "stats" => [
         %{
           "base_stat" => 60,
           "effort" => 0,
           "stat" => %{"name" => "hp", "url" => "https://pokeapi.co/api/v2/stat/1/"}
         },
         %{
           "base_stat" => 62,
           "effort" => 0,
           "stat" => %{"name" => "attack", "url" => "https://pokeapi.co/api/v2/stat/2/"}
         },
         %{
           "base_stat" => 63,
           "effort" => 0,
           "stat" => %{"name" => "defense", "url" => "https://pokeapi.co/api/v2/stat/3/"}
         },
         %{
           "base_stat" => 80,
           "effort" => 1,
           "stat" => %{"name" => "special-attack", "url" => "https://pokeapi.co/api/v2/stat/4/"}
         },
         %{
           "base_stat" => 80,
           "effort" => 0,
           "stat" => %{"name" => "special-defense", "url" => "https://pokeapi.co/api/v2/stat/5/"}
         },
         %{
           "base_stat" => 60,
           "effort" => 0,
           "stat" => %{"name" => "speed", "url" => "https://pokeapi.co/api/v2/stat/6/"}
         }
       ],
       "moves" => [
         %{
           "move" => %{"name" => "tackle", "url" => "https://pokeapi.co/api/v2/move/33/"},
           "version_group_details" => [
             %{
               "level_learned_at" => 1,
               "move_learn_method" => %{
                 "name" => "level-up",
                 "url" => "https://pokeapi.co/api/v2/move-learn-method/1/"
               },
               "version_group" => %{
                 "name" => "red-blue",
                 "url" => "https://pokeapi.co/api/v2/version-group/1/"
               }
             }
           ]
         }
       ],
       "sprites" => %{
         "front_default" =>
           "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/2.png",
         "back_default" =>
           "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/2.png",
         "front_shiny" =>
           "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/2.png",
         "back_shiny" =>
           "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/shiny/2.png",
         "front_female" => nil,
         "back_female" => nil,
         "front_shiny_female" => nil,
         "back_shiny_female" => nil
       },
       "game_indices" => [
         %{
           "game_index" => 2,
           "version" => %{"name" => "red", "url" => "https://pokeapi.co/api/v2/version/1/"}
         },
         %{
           "game_index" => 2,
           "version" => %{"name" => "blue", "url" => "https://pokeapi.co/api/v2/version/2/"}
         }
       ]
     }}
  end

  def overgrow_ability do
    {:ok,
     %{
       "name" => "overgrow",
       "id" => 65,
       "is_main_series" => true,
       "generation" => %{"name" => "generation-iii"},
       "effect_entries" => [
         %{
           "effect" =>
             "When this Pokémon has 1/3 or less of its HP remaining, its grass-type moves inflict 1.5× as much regular damage.",
           "short_effect" => "Strengthens grass moves to inflict 1.5× damage at 1/3 max HP or less.",
           "language" => %{"name" => "en"}
         }
       ]
     }}
  end

  def chlorophyll_ability do
    {:ok,
     %{
       "name" => "chlorophyll",
       "id" => 34,
       "is_main_series" => true,
       "generation" => %{"name" => "generation-iii"},
       "effect_entries" => [
         %{
           "effect" =>
             "This Pokémon's Speed is doubled during strong sunlight.",
           "short_effect" => "Doubles Speed during strong sunlight.",
           "language" => %{"name" => "en"}
         }
       ]
     }}
  end

  def grass_type do
    {:ok,
     %{
       "name" => "grass",
       "id" => 12,
       "generation" => %{"name" => "generation-i"},
       "move_damage_class" => %{"name" => "special"},
       "moves" => [],
       "pokemon" => []
     }}
  end

  def poison_type do
    {:ok,
     %{
       "name" => "poison",
       "id" => 4,
       "generation" => %{"name" => "generation-i"},
       "move_damage_class" => %{"name" => "physical"},
       "moves" => [],
       "pokemon" => []
     }}
  end

  def hp_stat do
    {:ok,
     %{
       "name" => "hp",
       "id" => 1,
       "game_index" => 1,
       "is_battle_only" => false,
       "affecting_moves" => %{"increase" => [], "decrease" => []},
       "affecting_natures" => %{"increase" => [], "decrease" => []}
     }}
  end

  def attack_stat do
    {:ok,
     %{
       "name" => "attack",
       "id" => 2,
       "game_index" => 2,
       "is_battle_only" => false,
       "affecting_moves" => %{"increase" => [], "decrease" => []},
       "affecting_natures" => %{"increase" => [], "decrease" => []}
     }}
  end

  def defense_stat do
    {:ok,
     %{
       "name" => "defense",
       "id" => 3,
       "game_index" => 3,
       "is_battle_only" => false,
       "affecting_moves" => %{"increase" => [], "decrease" => []},
       "affecting_natures" => %{"increase" => [], "decrease" => []}
     }}
  end

  def special_attack_stat do
    {:ok,
     %{
       "name" => "special-attack",
       "id" => 4,
       "game_index" => 4,
       "is_battle_only" => false,
       "affecting_moves" => %{"increase" => [], "decrease" => []},
       "affecting_natures" => %{"increase" => [], "decrease" => []}
     }}
  end

  def special_defense_stat do
    {:ok,
     %{
       "name" => "special-defense",
       "id" => 5,
       "game_index" => 5,
       "is_battle_only" => false,
       "affecting_moves" => %{"increase" => [], "decrease" => []},
       "affecting_natures" => %{"increase" => [], "decrease" => []}
     }}
  end

  def speed_stat do
    {:ok,
     %{
       "name" => "speed",
       "id" => 6,
       "game_index" => 6,
       "is_battle_only" => false,
       "affecting_moves" => %{"increase" => [], "decrease" => []},
       "affecting_natures" => %{"increase" => [], "decrease" => []}
     }}
  end

  def tackle_move do
    {:ok,
     %{
       "name" => "tackle",
       "id" => 33,
       "accuracy" => 100,
       "power" => 40,
       "pp" => 35,
       "priority" => 0,
       "generation" => %{"name" => "generation-i"},
       "type" => %{"name" => "normal"},
       "damage_class" => %{"name" => "physical"},
       "effect_entries" => [
         %{
           "effect" => "Inflicts regular damage with no additional effect.",
           "short_effect" => "Inflicts regular damage with no additional effect.",
           "language" => %{"name" => "en"}
         }
       ]
     }}
  end

  def red_blue_version_group do
    {:ok,
     %{
       "name" => "red-blue",
       "id" => 1,
       "order" => 1,
       "generation" => %{"name" => "generation-i"},
       "versions" => [
         %{"name" => "red", "url" => "https://pokeapi.co/api/v2/version/1/"},
         %{"name" => "blue", "url" => "https://pokeapi.co/api/v2/version/2/"}
       ]
     }}
  end

  def yellow_version_group do
    {:ok,
     %{
       "name" => "yellow",
       "id" => 2,
       "order" => 2,
       "generation" => %{"name" => "generation-i"},
       "versions" => [
         %{"name" => "yellow", "url" => "https://pokeapi.co/api/v2/version/3/"}
       ]
     }}
  end

  def red_game_version do
    {:ok,
     %{
       "name" => "red",
       "id" => 1,
       "version_group" => %{"name" => "red-blue", "url" => "https://pokeapi.co/api/v2/version-group/1/"}
     }}
  end

  def blue_game_version do
    {:ok,
     %{
       "name" => "blue",
       "id" => 2,
       "version_group" => %{"name" => "red-blue", "url" => "https://pokeapi.co/api/v2/version-group/1/"}
     }}
  end

  def yellow_game_version do
    {:ok,
     %{
       "name" => "yellow",
       "id" => 3,
       "version_group" => %{"name" => "yellow", "url" => "https://pokeapi.co/api/v2/version-group/2/"}
     }}
  end
end
