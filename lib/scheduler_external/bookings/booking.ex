defmodule SchedulerExternal.Bookings.Booking do
  @moduledoc """
  The Booking schema.

  After a user selects a timeslot, the user is redirected to a form to collect their name and email address.
  Once this information is collected, a booking is created with a TTL of 5 minutes.
  The booking is then sent to Nylas via API and ultimately synced to the user's calendar.
  Next, the user is redirected to a payment page and payment is collected.
  Once payment is collected, the booking is marked as confirmed and the vendor event is updated to invite the user.

  Statuses:
    - `pending`: booking has been created with a TTL, the end user has not been invited, but the source calendar has been blocked for the duration of the event
    - `confirmed`: booking has been paid and the end user has been invited to the event
    - `cancelled`: payment failed or the TTL for the pending event expired (e.g. no payment was received)

  Note: booking statuses are different than the Nylas job statuses, see `SchedulerExternal.Integrations.VendorJob` for more details.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "bookings" do
    field :email_address, :string
    field :end_time, :integer
    field :first_name, :string
    field :last_name, :string
    field :start_time, :integer
    field :vendor_id, :string
    field :payment_session_id, :string
    field :ttl, :utc_datetime
    field :status, Ecto.Enum, values: [:pending, :confirmed, :cancelled], default: :pending

    belongs_to :page, SchedulerExternal.Pages.Page
    has_many :vendor_jobs, SchedulerExternal.Integrations.VendorJob

    timestamps()
  end

  @doc false
  def changeset(booking, attrs) do
    booking
    |> cast(attrs, [:vendor_id, :start_time, :end_time, :first_name, :last_name, :email_address, :page_id, :payment_session_id, :ttl, :status])
    |> validate_required([:start_time, :end_time, :first_name, :last_name, :email_address, :page_id, :status])
  end
end
