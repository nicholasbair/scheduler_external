defmodule SchedulerExternal.Repo.Migrations.CreateBookings do
  use Ecto.Migration

  def change do
    create table(:bookings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :vendor_id, :string
      add :start_time, :integer
      add :end_time, :integer
      add :paid, :boolean, default: false, null: false
      add :vendor_job_id, :string
      add :first_name, :string
      add :last_name, :string
      add :email_address, :string
      add :vendor_confirmed, :boolean, default: false, null: false
      add :page_id, references(:pages, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:bookings, [:page_id])
  end
end
