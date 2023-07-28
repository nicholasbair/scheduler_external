defmodule SchedulerExternal.Repo.Migrations.UpdateValidIntegation do
  use Ecto.Migration

  def change do
    rename table(:integrations), :valid, to: :valid?
  end
end
