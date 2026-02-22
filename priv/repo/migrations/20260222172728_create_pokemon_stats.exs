defmodule Pokeql.Repo.Migrations.CreatePokemonStats do
  use Ecto.Migration

  def change do
    create table(:pokemon_stats) do
      add :pokemon_id, references(:pokemons, on_delete: :delete_all), null: false
      add :stat_id, references(:stats, on_delete: :restrict), null: false
      add :base_stat, :integer, null: false
      add :effort, :integer, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:pokemon_stats, [:pokemon_id, :stat_id])
    create index(:pokemon_stats, [:pokemon_id])
    create index(:pokemon_stats, [:stat_id])
    create index(:pokemon_stats, [:base_stat])

    create constraint(:pokemon_stats, :base_stat_must_be_valid,
           check: "base_stat >= 1 AND base_stat <= 255")
    create constraint(:pokemon_stats, :effort_must_be_valid,
           check: "effort >= 0 AND effort <= 3")
  end
end
