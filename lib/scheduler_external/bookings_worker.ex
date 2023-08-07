defmodule SchedulerExternal.Bookings.Worker do
  require Logger

  alias SchedulerExternal.{
    Integrations.Provider,
    Integrations.VendorJobs,
    Bookings
  }

  use Oban.Worker,
    queue: :bookings,
    max_attempts: 3

  @impl true
  def perform(%{args: %{"task" => "check_stale_integrations"}}) do
    check_unpaid_bookings()
  end

  defp check_unpaid_bookings() do
    Logger.info("Checking for unpaid bookings")

    Bookings.list_unpaid_bookings()
    |> Enum.each(&check_booking/1)

    :ok
  end

  defp check_booking(booking) do
    with true <- expired?(booking),
      {:ok, %{"job_status_id" => vendor_job_id}} <- Provider.cancel_event(booking.page.integration, booking.vendor_id),
      {:ok, booking} <- Bookings.update_booking(booking, %{status: :cancelled}),
      {:ok, _vendor_job} <- VendorJobs.create_vendor_job(%{booking_id: booking.id, vendor_id: vendor_job_id, vendor_object_id: booking.vendor_id, action: :delete}) do
        Logger.info("Successfully cancelled expired/unpaid booking with id #{booking.id}")
    end
  end

  defp expired?(booking) do
    case DateTime.compare(DateTime.utc_now(), booking.ttl) do
      :gt -> true
      _ -> false
    end
  end
end
