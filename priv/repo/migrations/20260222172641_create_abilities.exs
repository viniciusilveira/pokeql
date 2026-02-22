defmodule Pokeql.Repo.Migrations.CreateAbilities do
  use Ecto.Migration

  def change do
    create table(:abilities) do
      add :name, :string, null: false
      add :short_effect, :text
      add :generation_name, :string, null: false
      add :is_main_series, :boolean, null: false, default: true

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:abilities, [:name])
    create index(:abilities, [:generation_name])
    create index(:abilities, [:is_main_series])
  end
end
