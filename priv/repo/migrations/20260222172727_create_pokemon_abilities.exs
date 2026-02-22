defmodule Pokeql.Repo.Migrations.CreatePokemonAbilities do
  use Ecto.Migration

  def change do
    create table(:pokemon_abilities) do
      add :pokemon_id, references(:pokemons, on_delete: :delete_all), null: false
      add :ability_id, references(:abilities, on_delete: :restrict), null: false
      add :slot, :integer, null: false
      add :is_hidden, :boolean, null: false, default: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:pokemon_abilities, [:pokemon_id, :slot])
    create index(:pokemon_abilities, [:pokemon_id])
    create index(:pokemon_abilities, [:ability_id])
    create index(:pokemon_abilities, [:is_hidden])

    create constraint(:pokemon_abilities, :slot_must_be_valid,
           check: "slot >= 1 AND slot <= 3")
  end
end
