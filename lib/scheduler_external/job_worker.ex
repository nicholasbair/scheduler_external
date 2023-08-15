defmodule SchedulerExternal.Jobs.Worker do
  @moduledoc """
  The Jobs worker.

  This worker is responsible for updating the status for async jobs that are created on Nylas when the app creates and updates events on the organizer's calendar.
  At present, only the status of the job is updated, but in the future, we can add more logic to this worker to handle other things, such as notifying the user that the job failed, etc.
  """

  require Logger

  alias SchedulerExternal.{
    Integrations.VendorJobs
  }

  use Oban.Worker,
    queue: :jobs,
    max_attempts: 3

  @impl true
  def perform(%{args: %{"type" => type, "object_data" => %{"attributes" => %{"job_status_id" => job_id}}}}) do
    with {:ok, job} <- VendorJobs.get_job_by_vendor_id(job_id) do

      case type do
        "job.successful" ->
          {:ok, _} = VendorJobs.update_vendor_job(job, %{status: :successful})
          Logger.info("Processed successful job: #{job_id}")

        "job.failed" ->
          # Ideally do more than just mark the job as failed here
          # E.g. notify the user that some part of the booking process failed, etc.
          # No need to delete the event on Nylas, as it would be rolled back automatically when the job fails (if the action was create)
          {:ok, _} = VendorJobs.update_vendor_job(job, %{status: :failed})
          Logger.info("Processed failed job: #{job_id}")

        _ ->
          raise "Unknown job type: #{type}"
      end
    end

    :ok
  end
end
