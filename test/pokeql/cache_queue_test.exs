defmodule Pokeql.CacheQueueTest do
  use Pokeql.DataCase, async: false

  alias Pokeql.Cache
  alias Pokeql.CacheQueue

  setup do
    Cache.clear()
    :ok
  end

  describe "prewarm/0" do
    test "loads all types into the cache" do
      insert(:type, name: "fire")
      insert(:type, name: "water")

      CacheQueue.prewarm()
      Process.sleep(50)

      assert {:ok, fire} = Cache.get_type("fire")
      assert fire.name == "fire"

      assert {:ok, water} = Cache.get_type("water")
      assert water.name == "water"
    end

    test "loads all stats into the cache" do
      insert(:stat, name: "hp")
      insert(:stat, name: "attack")

      CacheQueue.prewarm()
      Process.sleep(50)

      assert {:ok, hp} = Cache.get_stat("hp")
      assert hp.name == "hp"

      assert {:ok, attack} = Cache.get_stat("attack")
      assert attack.name == "attack"
    end

    test "is a no-op when DB is empty (no crash)" do
      assert :ok = CacheQueue.prewarm()
    end
  end
end
