defmodule SchedulerExternal.Repo.Migrations.UpdatePageValid do
  use Ecto.Migration

  def change do
    rename table(:pages), :valid, to: :valid?
  end
end
