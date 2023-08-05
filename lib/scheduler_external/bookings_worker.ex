defmodule SchedulerExternal.Bookings.Worker do
  require Logger

  alias SchedulerExternal.Integrations
  alias SchedulerExternal.Integrations.Provider
  alias SchedulerExternal.Pages
  alias SchedulerExternal.Bookings

  use Oban.Worker,
    queue: :bookings,
    max_attempts: 3

  @impl true
  def perform(%{args: %{"task" => "check_stale_integrations"}}) do
    check_unpaid_bookings()
  end

  defp check_unpaid_bookings() do
    Logger.info("Checking for unpaid bookings")

    with {:ok, bookings} <- Bookings.list_unpaid_bookings() do
      Enum.each(bookings, &check_booking/1)
    end

    :ok
  end

  defp check_booking(booking) do
    with true <- expired?(booking),
      {:ok, page} <- Pages.get_page(booking.page_id),
      {:ok, _success} <- Provider.cancel_event(page.integration, booking.vendor_id),
      {:ok, _booking} <- Bookings.delete_booking(booking.id) do
        Logger.info("Successfully deleted expired/unpaid booking with id #{booking.id}")
    end
  end

  defp expired?(booking) do
    case DateTime.compare(DateTime.utc_now(), booking.ttl) do
      :gt -> true
      _ -> false
    end
  end
end
