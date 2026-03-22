defmodule PokeqlWeb.Schema.ReferenceQueryTest do
  use Pokeql.DataCase

  import Mox

  alias Pokeql.Cache

  setup :verify_on_exit!

  setup do
    Cache.clear()
    stub(Pokeql.PokeAPIMock, :get_pokemon, fn _ -> {:error, {:http_error, 404}} end)
    stub(Pokeql.PokeAPIMock, :get_species, fn _ -> {:error, {:http_error, 404}} end)
    :ok
  end

  # ---------------------------------------------------------------------------
  # Ability queries
  # ---------------------------------------------------------------------------

  describe "ability(name:) query" do
    test "returns ability by name" do
      ability = insert(:ability, name: "overgrow")

      query = """
      query {
        ability(name: "overgrow") {
          id
          name
          isMainSeries
          shortEffect
        }
      }
      """

      assert {:ok, %{data: %{"ability" => result}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert result["id"] == to_string(ability.id)
      assert result["name"] == "overgrow"
    end

    test "returns nil for unknown ability" do
      query = """
      query { ability(name: "nonexistent") { id } }
      """

      assert {:ok, %{data: %{"ability" => nil}}} = Absinthe.run(query, PokeqlWeb.Schema)
    end
  end

  describe "abilities query" do
    test "returns list of abilities" do
      insert_list(3, :ability)

      query = """
      query { abilities(limit: 3) { id name } }
      """

      assert {:ok, %{data: %{"abilities" => results}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert length(results) >= 3
    end

    test "respects limit and offset" do
      insert_list(5, :ability)

      query = """
      query { abilities(limit: 2, offset: 0) { id } }
      """

      assert {:ok, %{data: %{"abilities" => results}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert length(results) == 2
    end
  end

  # ---------------------------------------------------------------------------
  # Type queries
  # ---------------------------------------------------------------------------

  describe "type(name:) query" do
    test "returns type by name" do
      type = insert(:type, name: "fire")

      query = """
      query {
        type(name: "fire") {
          id
          name
          generationName
          damageClassName
        }
      }
      """

      assert {:ok, %{data: %{"type" => result}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert result["id"] == to_string(type.id)
      assert result["name"] == "fire"
    end

    test "returns nil for unknown type" do
      query = """
      query { type(name: "shadow") { id } }
      """

      assert {:ok, %{data: %{"type" => nil}}} = Absinthe.run(query, PokeqlWeb.Schema)
    end
  end

  describe "types query" do
    test "returns all types" do
      insert_list(3, :type)

      query = """
      query { types { id name } }
      """

      assert {:ok, %{data: %{"types" => results}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert length(results) >= 3
    end
  end

  # ---------------------------------------------------------------------------
  # Stat queries
  # ---------------------------------------------------------------------------

  describe "stat(name:) query" do
    test "returns stat by name" do
      stat = insert(:stat, name: "hp")

      query = """
      query {
        stat(name: "hp") {
          id
          name
          gameIndex
          isBattleOnly
        }
      }
      """

      assert {:ok, %{data: %{"stat" => result}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert result["id"] == to_string(stat.id)
      assert result["name"] == "hp"
    end

    test "returns nil for unknown stat" do
      query = """
      query { stat(name: "unknown-stat") { id } }
      """

      assert {:ok, %{data: %{"stat" => nil}}} = Absinthe.run(query, PokeqlWeb.Schema)
    end
  end

  describe "stats query" do
    test "returns all stats" do
      insert_list(2, :stat)

      query = """
      query { stats { id name gameIndex } }
      """

      assert {:ok, %{data: %{"stats" => results}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert length(results) >= 2
    end
  end

  # ---------------------------------------------------------------------------
  # Move queries
  # ---------------------------------------------------------------------------

  describe "move(name:) query" do
    test "returns move by name" do
      move = insert(:move, name: "tackle")

      query = """
      query {
        move(name: "tackle") {
          id
          name
          power
          pp
          accuracy
          priority
          typeName
          damageClassName
        }
      }
      """

      assert {:ok, %{data: %{"move" => result}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert result["id"] == to_string(move.id)
      assert result["name"] == "tackle"
    end

    test "returns nil for unknown move" do
      query = """
      query { move(name: "nonexistent-move") { id } }
      """

      assert {:ok, %{data: %{"move" => nil}}} = Absinthe.run(query, PokeqlWeb.Schema)
    end
  end

  describe "moves query" do
    test "returns list of moves" do
      insert_list(3, :move)

      query = """
      query { moves(limit: 3) { id name } }
      """

      assert {:ok, %{data: %{"moves" => results}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert length(results) >= 3
    end

    test "respects limit and offset" do
      insert_list(5, :move)

      query = """
      query { moves(limit: 2, offset: 0) { id } }
      """

      assert {:ok, %{data: %{"moves" => results}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert length(results) == 2
    end
  end

  # ---------------------------------------------------------------------------
  # Species queries
  # ---------------------------------------------------------------------------

  describe "species(name:) query" do
    test "returns species by name" do
      species = insert(:species, name: "bulbasaur", is_legendary: false, is_mythical: false)

      query = """
      query {
        species(name: "bulbasaur") {
          id
          name
          isLegendary
          isMythical
          generationName
        }
      }
      """

      assert {:ok, %{data: %{"species" => result}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert result["id"] == to_string(species.id)
      assert result["name"] == "bulbasaur"
      assert result["isLegendary"] == false
      assert result["isMythical"] == false
    end

    test "returns nil for unknown species" do
      query = """
      query { species(name: "fakemon") { id } }
      """

      assert {:ok, %{data: %{"species" => nil}}} = Absinthe.run(query, PokeqlWeb.Schema)
    end
  end

  describe "speciesList query" do
    test "returns all species" do
      insert_list(3, :species)

      query = """
      query { speciesList { id name } }
      """

      assert {:ok, %{data: %{"speciesList" => results}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert length(results) >= 3
    end
  end

  # ---------------------------------------------------------------------------
  # Version group queries
  # ---------------------------------------------------------------------------

  describe "versionGroup(name:) query" do
    test "returns version group by name" do
      vg =
        insert(:version_group, name: "red-blue", generation_name: "generation-i", sort_order: 1)

      query = """
      query {
        versionGroup(name: "red-blue") {
          id
          name
          generationName
          sortOrder
        }
      }
      """

      assert {:ok, %{data: %{"versionGroup" => result}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert result["id"] == to_string(vg.id)
      assert result["name"] == "red-blue"
      assert result["generationName"] == "generation-i"
    end

    test "returns nil for unknown version group" do
      query = """
      query { versionGroup(name: "nonexistent") { id } }
      """

      assert {:ok, %{data: %{"versionGroup" => nil}}} = Absinthe.run(query, PokeqlWeb.Schema)
    end
  end

  describe "versionGroups query" do
    test "returns all version groups" do
      insert(:version_group, sort_order: 1)
      insert(:version_group, sort_order: 2)

      query = """
      query { versionGroups { id name sortOrder } }
      """

      assert {:ok, %{data: %{"versionGroups" => results}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert length(results) >= 2
    end
  end

  # ---------------------------------------------------------------------------
  # Legendary / Mythical
  # ---------------------------------------------------------------------------

  describe "legendaryPokemons query" do
    test "returns only legendary pokemon" do
      legendary_species = insert(:legendary_species)
      _legendary = insert(:pokemon, species: legendary_species)

      query = """
      query { legendaryPokemons { id name species { isLegendary } } }
      """

      assert {:ok, %{data: %{"legendaryPokemons" => results}}} =
               Absinthe.run(query, PokeqlWeb.Schema)

      assert results != []
      assert Enum.all?(results, fn p -> p["species"]["isLegendary"] == true end)
    end
  end

  describe "mythicalPokemons query" do
    test "returns only mythical pokemon" do
      mythical_species = insert(:mythical_species)
      _mythical = insert(:pokemon, species: mythical_species)

      query = """
      query { mythicalPokemons { id name species { isMythical } } }
      """

      assert {:ok, %{data: %{"mythicalPokemons" => results}}} =
               Absinthe.run(query, PokeqlWeb.Schema)

      assert results != []
      assert Enum.all?(results, fn p -> p["species"]["isMythical"] == true end)
    end
  end

  # ---------------------------------------------------------------------------
  # Pokemon moves with version_group argument
  # ---------------------------------------------------------------------------

  describe "pokemon moves with version_group argument" do
    test "returns move details for a given version group" do
      version_group = insert(:version_group, name: "red-blue", sort_order: 1)
      move = insert(:move, name: "tackle")
      pokemon = insert(:pokemon)
      pokemon_move = insert(:pokemon_move, pokemon: pokemon, move: move)

      insert(:pokemon_move_version_detail,
        pokemon_move: pokemon_move,
        version_group: version_group,
        level_learned_at: 1,
        learn_method: "level-up"
      )

      query = """
      query {
        pokemon(id: #{pokemon.id}) {
          moves(versionGroup: "red-blue") {
            levelLearnedAt
            learnMethod
            move { name }
            versionGroup { name }
          }
        }
      }
      """

      assert {:ok, %{data: %{"pokemon" => result}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert length(result["moves"]) == 1
      assert hd(result["moves"])["move"]["name"] == "tackle"
      assert hd(result["moves"])["levelLearnedAt"] == 1
      assert hd(result["moves"])["learnMethod"] == "level-up"
    end

    test "returns flat move list when no version_group given" do
      move = insert(:move, name: "scratch")
      pokemon = insert(:pokemon)
      insert(:pokemon_move, pokemon: pokemon, move: move)

      query = """
      query {
        pokemon(id: #{pokemon.id}) {
          moves {
            move { name }
          }
        }
      }
      """

      assert {:ok, %{data: %{"pokemon" => result}}} = Absinthe.run(query, PokeqlWeb.Schema)
      assert length(result["moves"]) == 1
      assert hd(result["moves"])["move"]["name"] == "scratch"
    end
  end
end
