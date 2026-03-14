defmodule Pokeql.Repo.Migrations.CreatePokemonTypes20260222172730 do
  use Ecto.Migration

  def change do
    create table(:pokemon_types) do
      add :pokemon_id, references(:pokemons, on_delete: :delete_all), null: false
      add :type_id, references(:types, on_delete: :restrict), null: false
      add :slot, :integer, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:pokemon_types, [:pokemon_id, :slot])
    create index(:pokemon_types, [:pokemon_id])
    create index(:pokemon_types, [:type_id])

    create constraint(:pokemon_types, :slot_must_be_valid,
           check: "slot >= 1 AND slot <= 2")
  end
end
