defmodule SchedulerExternal.Repo.Migrations.Createpages do
  use Ecto.Migration

  def change do
    create table(:pages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :valid, :boolean, default: false, null: false
      add :vendor_id, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :integration_id, references(:integrations, on_delete: :nothing, type: :binary_id)
      add :title, :string
      add :cost, :integer
      add :slug, :string

      timestamps()
    end

    create index(:pages, [:user_id])
    create index(:pages, [:integration_id])
  end
end
