defmodule SchedulerExternal.Repo.Migrations.AddCalendarIdToPage do
  use Ecto.Migration

  def change do
    alter table(:pages) do
      add :calendar_id, :string
    end
  end
end
