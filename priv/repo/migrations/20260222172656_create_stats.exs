defmodule Pokeql.Repo.Migrations.CreateStats do
  use Ecto.Migration

  def change do
    create table(:stats) do
      add :name, :string, null: false
      add :game_index, :integer, null: false
      add :is_battle_only, :boolean, null: false, default: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:stats, [:name])
    create index(:stats, [:game_index])
    create index(:stats, [:is_battle_only])

    create constraint(:stats, :game_index_non_negative, check: "game_index >= 0")
  end
end
