defmodule SchedulerExternal.Repo.Migrations.CreateIntegrations do
  use Ecto.Migration

  def change do
    create table(:integrations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :valid, :boolean, default: false, null: false
      add :token, :string
      add :vendor_id, :string
      add :email_address, :string
      add :invalid_since, :utc_datetime
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:integrations, [:user_id])
  end
end
