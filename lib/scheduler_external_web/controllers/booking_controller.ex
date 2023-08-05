defmodule SchedulerExternalWeb.BookingController do
  use SchedulerExternalWeb, :controller

  alias SchedulerExternal.{Bookings, Pages, Integrations}
  alias SchedulerExternal.Integrations.{
    Provider,
    PaymentProvider
  }

  def payment(conn, params) do
    booking = Bookings.get_booking!(params["booking_id"])
    stripe_params = PaymentProvider.build_payment_params(booking.page.cost, booking.page.title)

    with {:ok, %{id: session_id, url: session_url} = _session} <- Stripe.Session.create(stripe_params),
        {:ok, _booking} <- Bookings.update_booking(booking, %{payment_session_id: session_id}) do
          conn
          |> put_status(303)
          |> redirect(external: session_url)
      end

    conn
    |> put_status(500)
  end

  def success(conn, params) do
    with {:ok, booking} <- Bookings.get_booking_by_payment_session(params["session_id"]),
      {:ok, event} <- Provider.confirm_event(booking.page.integration, booking, booking.page) do
        Bookings.update_booking(booking, %{paid: true, vendor_job_id: event.job_status_id})
        render(conn, "success.html")
    end

    resp(conn, 500, "Something went wrong")
  end

  def cancel(conn, params) do
    with {:ok, booking} <- Bookings.get_booking_by_payment_session(params["session_id"]),
      {:ok, _} <- Provider.cancel_event(booking.page.integration, booking),
      {:ok, _} <- Bookings.delete_booking(booking) do
        render(conn, "cancel.html")
    end

    resp(conn, 500, "Something went wrong")
  end
end
