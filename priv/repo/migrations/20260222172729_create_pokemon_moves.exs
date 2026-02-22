defmodule Pokeql.Repo.Migrations.CreatePokemonMoves do
  use Ecto.Migration

  def change do
    create table(:pokemon_moves) do
      add :pokemon_id, references(:pokemons, on_delete: :delete_all), null: false
      add :move_id, references(:moves, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:pokemon_moves, [:pokemon_id, :move_id])
    create index(:pokemon_moves, [:pokemon_id])
    create index(:pokemon_moves, [:move_id])
  end
end
