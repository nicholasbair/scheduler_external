defmodule SchedulerExternal.Repo.Migrations.AddTtlToBookings do
  use Ecto.Migration

  def change do
    alter table(:bookings) do
      add :ttl, :utc_datetime
    end
  end
end
