defmodule SchedulerExternal.Repo.Migrations.AddPaymentSessionIdToBooking do
  use Ecto.Migration

  def change do
    alter table(:bookings) do
      add :payment_session_id, :string
    end
  end
end
