defmodule Pokeql.Repo.Migrations.CreateVersionGroups20260222172660 do
  use Ecto.Migration

  def change do
    create table(:version_groups) do
      add :name, :string, null: false
      add :generation_name, :string, null: false
      add :sort_order, :integer, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:version_groups, [:name])
    create index(:version_groups, [:generation_name])
    create index(:version_groups, [:sort_order])

    create constraint(:version_groups, :sort_order_positive, check: "sort_order > 0")
  end
end
