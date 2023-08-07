defmodule SchedulerExternal.Integrations.VendorJob do
  @moduledoc """
  The VendorJob schema.

  The `VendorJob` represents a asynchronous job on Nylas (the vendor) which tracks the operation of syncing the event from Nylas to the calendar provider.

  Statuses:
    - `pending`: job has been created and is waiting to be processed
    - `successful`: a `job.successful` webhook was recieved from Nylas and the event has been synced to the calendar provider
    - `failed`: a `job.failed` webhook was recieved from Nylas and the event has not been synced to the calendar provider

  Note:
    - Async jobs on Nylas have retry and backoff built in, so if a a job is failed, the operation was retried 10+ times.
    - The `VendorJob` status is different than the `Booking` status, see `SchedulerExternal.Bookings.Booking` for more details.
    - At present, a failed job does not propagate to the booking status, so a booking can be confirmed even if the job failed.
      - This may result in double bookings and requires manual intervention to resolve.
      - But I think keeping the booking and requiring manual intervention is better than wholesale cancelling bookings/events with failed jobs.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "vendor_jobs" do
    field :vendor_id, :string
    field :vendor_object_id, :string
    field :status, Ecto.Enum, values: [:pending, :successful, :failed], default: :pending
    field :action, Ecto.Enum, values: [:create, :update, :cancel], default: :create

    belongs_to :booking, SchedulerExternal.Bookings.Booking

    timestamps()
  end

  @doc false
  def changeset(vendor_job, attrs) do
    vendor_job
    |> cast(attrs, [:vendor_object_id, :vendor_id, :status, :action])
    |> validate_required([:vendor_object_id, :vendor_id, :status, :action])
  end
end
