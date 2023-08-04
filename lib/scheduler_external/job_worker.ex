defmodule SchedulerExternal.Jobs.Worker do
  require Logger

  use Oban.Worker,
    queue: :jobs,
    max_attempts: 3


  @impl true
  def perform(%{args: %{"type" => "job.failed", "object_data" => %{"attributes" => %{"job_status_id" => job_id}}}}) do
    with {:ok, booking} <- SchedulerExternal.Bookings.get_booking_by_job(job_id) do

        # Ideally do more than just delete the booking here
        # E.g. notify the user that the booking failed, etc.
        # No need to delete the event on Nylas, as it would be rolled back automatically when the job fails
        SchedulerExternal.Bookings.delete_booking(booking)

        Logger.info("Processed failed job for booking id #{booking.id}")
      end

    :ok
  end
end
