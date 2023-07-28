defmodule SchedulerExternal.Repo.Migrations.AddDurLocationToPages do
  use Ecto.Migration

  def change do
    alter table(:pages) do
      add :duration, :integer
      add :location, :string
    end
  end
end
