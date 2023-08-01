defmodule SchedulerExternal.Repo.Migrations.AddPublicToPages do
  use Ecto.Migration

  def change do
    alter table(:pages) do
      add :public?, :boolean, default: false
    end
  end
end
