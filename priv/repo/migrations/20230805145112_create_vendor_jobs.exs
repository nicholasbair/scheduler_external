defmodule SchedulerExternal.Repo.Migrations.CreateVendorJobs do
  use Ecto.Migration

  def change do
    create table(:vendor_jobs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :vendor_object_id, :string
      add :vendor_id, :string
      add :booking_id, references(:bookings, on_delete: :nothing, type: :binary_id)
      add :status, :string
      add :action, :string

      timestamps()
    end

    create index(:vendor_jobs, [:booking_id])
  end
end
