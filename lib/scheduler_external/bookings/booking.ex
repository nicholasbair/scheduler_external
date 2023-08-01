defmodule SchedulerExternal.Bookings.Booking do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "bookings" do
    field :email_address, :string
    field :end_time, :integer
    field :first_name, :string
    field :last_name, :string
    field :paid, :boolean, default: false
    field :start_time, :integer
    field :vendor_confirmed, :boolean, default: false
    field :vendor_id, :string
    field :vendor_job_id, :string
    field :page_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [:vendor_id, :start_time, :end_time, :paid, :vendor_job_id, :first_name, :last_name, :email_address, :vendor_confirmed])
    |> validate_required([:vendor_id, :start_time, :end_time, :paid, :vendor_job_id, :first_name, :last_name, :email_address, :vendor_confirmed])
  end
end
