defmodule SchedulerExternal.Repo.Migrations.AddProfileRelationToPages do
  use Ecto.Migration

  def change do
    alter table(:pages) do
      add :profile_id, references(:profiles, on_delete: :nothing, type: :binary_id)
    end
  end
end
