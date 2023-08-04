defmodule SchedulerExternal.Repo.Migrations.RemoveValidFromPages do
  use Ecto.Migration

  def change do
    alter table(:pages) do
      remove :valid?
    end
  end
end
