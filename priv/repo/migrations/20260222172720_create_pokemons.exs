defmodule Pokeql.Repo.Migrations.CreatePokemons do
  use Ecto.Migration

  def change do
    create table(:pokemons) do
      add :name, :string, null: false
      add :height, :integer, null: false
      add :weight, :integer, null: false
      add :base_experience, :integer
      add :order, :integer, null: false
      add :is_default, :boolean, null: false, default: false
      add :species_id, references(:species, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:pokemons, [:name])
    create index(:pokemons, [:species_id])
    create index(:pokemons, [:order])
    create index(:pokemons, [:is_default])
    
    create constraint(:pokemons, :height_must_be_positive, check: "height > 0")
    create constraint(:pokemons, :weight_must_be_positive, check: "weight > 0")
    create constraint(:pokemons, :base_experience_must_be_non_negative, 
           check: "base_experience >= 0")
  end
end
