defmodule Pokeql.Repo.Migrations.CreateTypes do
  use Ecto.Migration

  def change do
    create table(:types) do
      add :name, :string, null: false
      add :generation_name, :string, null: false
      add :damage_class_name, :string

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:types, [:name])
    create index(:types, [:generation_name])
    create index(:types, [:damage_class_name])
  end
end
