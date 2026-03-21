defmodule PokeqlWeb.Schema.PokemonQueryTest do
  use Pokeql.DataCase

  import Mox

  alias Pokeql.Cache

  setup :verify_on_exit!

  setup do
    Cache.clear()
    # Stub API to return not-found so DB-miss lookups return nil without network calls
    stub(Pokeql.PokeAPIMock, :get_pokemon, fn _ -> {:error, {:http_error, 404}} end)
    stub(Pokeql.PokeAPIMock, :get_species, fn _ -> {:error, {:http_error, 404}} end)
    :ok
  end

  describe "pokemon(id:) query" do
    test "returns pokemon by id" do
      pokemon = insert(:pokemon, name: "bulbasaur")

      query = """
      query {
        pokemon(id: #{pokemon.id}) {
          id
          name
        }
      }
      """

      assert {:ok, %{data: %{"pokemon" => result}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert result["id"] == to_string(pokemon.id)
      assert result["name"] == "bulbasaur"
    end

    test "returns nil for non-existent id" do
      query = """
      query {
        pokemon(id: 999999) {
          id
          name
        }
      }
      """

      assert {:ok, %{data: %{"pokemon" => nil}}} = Absinthe.run(query, PokeqlWeb.Schema)
    end
  end

  describe "pokemon(name:) query" do
    test "returns pokemon by name" do
      pokemon = insert(:pokemon, name: "charmander")

      query = """
      query {
        pokemon(name: "charmander") {
          id
          name
        }
      }
      """

      assert {:ok, %{data: %{"pokemon" => result}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert result["id"] == to_string(pokemon.id)
      assert result["name"] == "charmander"
    end

    test "returns nil for non-existent name" do
      query = """
      query {
        pokemon(name: "unknownmon") {
          id
        }
      }
      """

      assert {:ok, %{data: %{"pokemon" => nil}}} = Absinthe.run(query, PokeqlWeb.Schema)
    end

    test "returns error when neither id nor name given" do
      query = """
      query {
        pokemon {
          id
        }
      }
      """

      assert {:ok, %{errors: errors}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert length(errors) > 0
    end
  end

  describe "pokemons query" do
    test "returns list of pokemons" do
      insert_list(3, :pokemon)

      query = """
      query {
        pokemons(limit: 3) {
          id
          name
        }
      }
      """

      assert {:ok, %{data: %{"pokemons" => results}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert length(results) >= 3
    end

    test "respects limit and offset" do
      insert_list(5, :pokemon)

      query = """
      query {
        pokemons(limit: 2, offset: 0) {
          id
        }
      }
      """

      assert {:ok, %{data: %{"pokemons" => results}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert length(results) == 2
    end

    test "filters by type" do
      type = insert(:type, name: "fire")
      pokemon = insert(:pokemon)
      insert(:pokemon_type, pokemon: pokemon, type: type, slot: 1)

      query = """
      query {
        pokemons(type: "fire") {
          id
          name
        }
      }
      """

      assert {:ok, %{data: %{"pokemons" => results}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert Enum.any?(results, fn p -> p["id"] == to_string(pokemon.id) end)
    end

    test "filters by ability" do
      ability = insert(:ability, name: "overgrow")
      pokemon = insert(:pokemon)
      insert(:pokemon_ability, pokemon: pokemon, ability: ability, slot: 1, is_hidden: false)

      query = """
      query {
        pokemons(ability: "overgrow") {
          id
          name
        }
      }
      """

      assert {:ok, %{data: %{"pokemons" => results}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert Enum.any?(results, fn p -> p["id"] == to_string(pokemon.id) end)
    end

    test "filters by generation" do
      gen_i_species = insert(:generation_i_species)
      pokemon = insert(:pokemon, species: gen_i_species)

      query = """
      query {
        pokemons(generation: "generation-i") {
          id
          name
        }
      }
      """

      assert {:ok, %{data: %{"pokemons" => results}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert Enum.any?(results, fn p -> p["id"] == to_string(pokemon.id) end)
    end

    test "search by partial name" do
      insert(:pokemon, name: "bulbasaur")

      query = """
      query {
        pokemons(search: "bulba") {
          id
          name
        }
      }
      """

      assert {:ok, %{data: %{"pokemons" => results}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert Enum.any?(results, fn p -> p["name"] == "bulbasaur" end)
    end
  end

  describe "nested fields" do
    test "species nested fields" do
      species = insert(:species, name: "bulbasaur", is_legendary: false, is_mythical: false)
      pokemon = insert(:pokemon, name: "bulbasaur", species: species)

      query = """
      query {
        pokemon(id: #{pokemon.id}) {
          id
          name
          species {
            name
            isLegendary
            isMythical
          }
        }
      }
      """

      assert {:ok, %{data: %{"pokemon" => result}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert result["species"]["name"] == "bulbasaur"
      assert result["species"]["isLegendary"] == false
      assert result["species"]["isMythical"] == false
    end

    test "sprites nested field" do
      pokemon = insert(:pokemon)
      insert(:sprite, pokemon: pokemon, front_default: "https://example.com/front.png")

      query = """
      query {
        pokemon(id: #{pokemon.id}) {
          id
          sprites {
            frontDefault
          }
        }
      }
      """

      assert {:ok, %{data: %{"pokemon" => result}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert result["sprites"]["frontDefault"] == "https://example.com/front.png"
    end
  end
end
