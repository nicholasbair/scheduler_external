defmodule SchedulerExternal.Repo.Migrations.AddSlugToProfiles do
  use Ecto.Migration

  def change do
    alter table(:profiles) do
      add :slug, :string
    end
  end
end
