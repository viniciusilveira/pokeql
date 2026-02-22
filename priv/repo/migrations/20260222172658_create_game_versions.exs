defmodule Pokeql.Repo.Migrations.CreateGameVersions do
  use Ecto.Migration

  def change do
    create table(:game_versions) do
      add :name, :string, null: false
      add :version_group_name, :string

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:game_versions, [:name])
    create index(:game_versions, [:version_group_name])
  end
end
