defmodule Pokeql.Repo.Migrations.CreatePokemonGameIndices do
  use Ecto.Migration

  def change do
    create table(:pokemon_game_indices) do
      add :pokemon_id, references(:pokemons, on_delete: :delete_all), null: false
      add :game_version_id, references(:game_versions, on_delete: :restrict), null: false
      add :game_index, :integer, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:pokemon_game_indices, [:pokemon_id, :game_version_id])
    create index(:pokemon_game_indices, [:pokemon_id])
    create index(:pokemon_game_indices, [:game_version_id])
    create index(:pokemon_game_indices, [:game_index])

    create constraint(:pokemon_game_indices, :game_index_must_be_positive,
           check: "game_index > 0")
  end
end
