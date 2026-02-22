defmodule Pokeql.Repo.Migrations.CreatePokemonMoveVersionDetails do
  use Ecto.Migration

  def change do
    create table(:pokemon_move_version_details) do
      add :pokemon_move_id, references(:pokemon_moves, on_delete: :delete_all), null: false
      add :version_group_id, references(:version_groups, on_delete: :restrict), null: false
      add :level_learned_at, :integer, null: false
      add :learn_method, :string, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:pokemon_move_version_details, [:pokemon_move_id, :version_group_id])
    create index(:pokemon_move_version_details, [:pokemon_move_id])
    create index(:pokemon_move_version_details, [:version_group_id])
    create index(:pokemon_move_version_details, [:level_learned_at])

    create constraint(:pokemon_move_version_details, :level_must_be_valid,
           check: "level_learned_at >= 0 AND level_learned_at <= 100")
  end
end
