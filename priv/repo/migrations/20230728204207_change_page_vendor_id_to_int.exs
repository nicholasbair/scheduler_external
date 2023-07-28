defmodule SchedulerExternal.Repo.Migrations.ChangePageVendorIdToInt do
  use Ecto.Migration

  def change do
    alter table(:pages) do
      remove :vendor_id
      add :vendor_id, :integer
    end
  end
end
