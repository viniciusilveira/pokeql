defmodule Pokeql.Repo.Migrations.CreateSprites20260222172741 do
  use Ecto.Migration

  def change do
    create table(:sprites) do
      add :pokemon_id, references(:pokemons, on_delete: :delete_all), null: false
      add :front_default, :string
      add :back_default, :string
      add :front_shiny, :string
      add :back_shiny, :string
      add :front_female, :string
      add :back_female, :string
      add :front_shiny_female, :string
      add :back_shiny_female, :string

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:sprites, [:pokemon_id])
  end
end
