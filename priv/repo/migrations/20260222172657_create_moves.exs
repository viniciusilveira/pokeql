defmodule Pokeql.Repo.Migrations.CreateMoves do
  use Ecto.Migration

  def change do
    create table(:moves) do
      add :name, :string, null: false
      add :accuracy, :integer
      add :power, :integer
      add :pp, :integer
      add :priority, :integer, null: false, default: 0
      add :damage_class_name, :string
      add :type_name, :string
      add :generation_name, :string, null: false
      add :short_effect, :text

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:moves, [:name])
    create index(:moves, [:type_name])
    create index(:moves, [:damage_class_name])
    create index(:moves, [:generation_name])
    create index(:moves, [:power])

    create constraint(:moves, :accuracy_valid,
           check: "accuracy IS NULL OR (accuracy >= 1 AND accuracy <= 100)")
    create constraint(:moves, :power_non_negative,
           check: "power IS NULL OR power >= 0")
    create constraint(:moves, :pp_positive, check: "pp IS NULL OR pp > 0")
    create constraint(:moves, :priority_valid,
           check: "priority >= -8 AND priority <= 5")
  end
end
