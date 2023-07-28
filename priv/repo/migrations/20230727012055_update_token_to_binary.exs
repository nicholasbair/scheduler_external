defmodule SchedulerExternal.Repo.Migrations.UpdateTokenToBinary do
  use Ecto.Migration

  def change do
    alter table(:integrations) do
      remove :token
      add :token, :binary
    end
  end
end
