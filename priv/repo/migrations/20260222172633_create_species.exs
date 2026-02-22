defmodule Pokeql.Repo.Migrations.CreateSpecies do
  use Ecto.Migration

  def change do
    create table(:species) do
      add :name, :string, null: false
      add :base_happiness, :integer, null: false, default: 0
      add :capture_rate, :integer, null: false, default: 45
      add :color_name, :string
      add :gender_rate, :integer, null: false, default: -1
      add :growth_rate_name, :string
      add :habitat_name, :string
      add :hatch_counter, :integer, null: false, default: 20
      add :is_baby, :boolean, null: false, default: false
      add :is_legendary, :boolean, null: false, default: false
      add :is_mythical, :boolean, null: false, default: false
      add :has_gender_differences, :boolean, null: false, default: false
      add :shape_name, :string
      add :generation_name, :string, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:species, [:name])
    create index(:species, [:generation_name])
    create index(:species, [:is_legendary])
    create index(:species, [:is_mythical])

    create constraint(:species, :capture_rate_valid, check: "capture_rate >= 0 AND capture_rate <= 255")
    create constraint(:species, :gender_rate_valid, check: "gender_rate >= -1 AND gender_rate <= 8")
  end
end
