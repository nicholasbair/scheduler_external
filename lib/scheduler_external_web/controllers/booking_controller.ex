defmodule SchedulerExternalWeb.BookingController do
  use SchedulerExternalWeb, :controller

  alias SchedulerExternal.{
    Bookings,
    Integrations.Provider,
    Integrations.PaymentProvider,
    Integrations.VendorJobs
  }

  def payment(conn, params) do
    booking = Bookings.get_booking!(params["booking_id"])
    stripe_params = PaymentProvider.build_payment_params(booking.page.cost, booking.page.title, booking.email_address)

    with {:ok, %{id: session_id, url: session_url} = _session} <- Stripe.Session.create(stripe_params),
        {:ok, _booking} <- Bookings.update_booking(booking, %{payment_session_id: session_id}) do
          conn
          |> put_status(303)
          |> redirect(external: session_url)
    else {:error, _} ->
      resp(conn, 500, "Something went wrong")
    end
  end

  def success(conn, params) do
    with {:ok, booking} <- Bookings.get_booking_by_payment_session(params["session_id"]),
      {:ok, event} <- Provider.confirm_event(booking.page.integration, booking, booking.page),
      {:ok, _} <- Bookings.update_booking(booking, %{status: :confirmed}),
      {:ok, _} <-  VendorJobs.create_vendor_job(%{booking_id: booking.id, vendor_id: event.job_status_id, vendor_object_id: event.id, action: :update}) do

        render(conn, "success.html")
    else {:error, _} ->
      resp(conn, 500, "Something went wrong")
    end
  end

  def cancel(conn, params) do
    with {:ok, booking} <- Bookings.get_booking_by_payment_session(params["session_id"]),
      {:ok, %{"job_status_id" => vendor_job_id}} <- Provider.cancel_event(booking.page.integration, booking),
      {:ok, _} <- VendorJobs.create_vendor_job(%{booking_id: booking.id, vendor_id: vendor_job_id, vendor_object_id: booking.vendor_id, action: :delete}),
      {:ok, _} <- Bookings.update_booking(booking, %{status: :cancelled}) do
        render(conn, "cancel.html")
    else {:error, _} ->
      resp(conn, 500, "Something went wrong")
    end
  end
end
