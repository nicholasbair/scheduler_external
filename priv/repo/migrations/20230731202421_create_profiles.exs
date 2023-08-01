defmodule SchedulerExternal.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :public?, :boolean, default: false, null: false
      add :name, :string
      add :description, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:profiles, [:user_id])
  end
end
