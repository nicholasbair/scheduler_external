defmodule SchedulerExternal.Repo.Migrations.AddStatusToBookings do
  use Ecto.Migration

  def change do
    alter table(:bookings) do
      add :status, :string
      remove :paid
    end
  end
end
