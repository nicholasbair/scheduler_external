defmodule SchedulerExternalWeb.BookingController do
  use SchedulerExternalWeb, :controller

  alias SchedulerExternal.{
    Bookings,
    Integrations.Provider,
    Integrations.PaymentProvider,
    Integrations.VendorJobs
  }

  def start_payment(conn, params) do
    booking = Bookings.get_booking!(params["booking_id"])
    stripe_params = PaymentProvider.build_payment_params(booking.page.cost, booking.page.title, booking.email_address)

    with {:ok, %{id: session_id, url: session_url} = _session} <- Stripe.Session.create(stripe_params),
        {:ok, _booking} <- Bookings.update_booking(booking, %{payment_session_id: session_id}) do
          conn
          |> put_status(303)
          |> redirect(external: session_url)
    else {:error, msg} ->
      resp(conn, 500, "Something went wrong: #{inspect(msg)}")
    end
  end

  def payment_success(conn, params) do
    with {:ok, booking} <- Bookings.get_booking_by_payment_session(params["session_id"]),
      {:ok, event} <- Provider.confirm_event(booking.page.integration, booking, booking.page),
      {:ok, _} <- Bookings.update_booking(booking, %{status: :confirmed}),
      {:ok, _} <-  VendorJobs.create_vendor_job(%{booking_id: booking.id, vendor_id: event.job_status_id, vendor_object_id: event.id, action: :update}) do

        render(conn, "success.html")
    else {:error, msg} ->
      resp(conn, 500, "Something went wrong: #{inspect(msg)}")
    end
  end

  def payment_cancel(conn, params) do
    with {:ok, booking} <- Bookings.get_booking_by_payment_session(params["session_id"]),
      {:ok, %{job_status_id: vendor_job_id}} <- Provider.cancel_event(booking.page.integration, booking),
      {:ok, _} <- VendorJobs.create_vendor_job(%{booking_id: booking.id, vendor_id: vendor_job_id, vendor_object_id: booking.vendor_id, action: :delete}),
      {:ok, _} <- Bookings.update_booking(booking, %{status: :cancelled}) do
        render(conn, "cancel.html")
    else {:error, msg} ->
      resp(conn, 500, "Something went wrong: #{inspect(msg)}")
    end
  end

  # Here the app is just cancelling the booking if the user clicks on the link
  # But in a real app, you would potentially want to:
    # 1. Send an email to the user to confirm the cancellation
    # 2. Send an email to the vendor to confirm the cancellation
    # 3. Enforces rules around cancellation notice/policy
    # 4. Refund money, less any late cancellation fees, etc.
  def booking_cancel(conn, params) do
    with {:ok, booking} <- Bookings.get_booking(params["id"]),
      {:ok, %{job_status_id: vendor_job_id}} <- Provider.cancel_event(booking.page.integration, booking),
      {:ok, _} <- VendorJobs.create_vendor_job(%{booking_id: booking.id, vendor_id: vendor_job_id, vendor_object_id: booking.vendor_id, action: :cancel}),
      {:ok, _} <- Bookings.update_booking(booking, %{status: :cancelled}) do
        render(conn, "cancel_booking.html")
    else {:error, msg} ->
      resp(conn, 500, "Something went wrong: #{inspect(msg)}")
    end
  end

  # Here the app is allowing the user to reschedule the meeting, even with very little notice, etc.
  # In a real app, you may want to:
    # 1. Enforce rules around rescheduling notice/policy
    # 2. Send an email to the user to confirm the reschedule
    # 3. Send an email to the vendor to confirm the reschedule
    # 4. Track if a booking has been rescheduled, number of times, etc.
  def booking_reschedule(conn, params) do
    with {:ok, %{status: :confirmed} = booking} <- Bookings.get_booking(params["id"]) do
      redirect(conn, to: "/services/#{booking.page.slug}?#{URI.encode_query(%{booking_id: booking.id, reschedule: true})}")
    else {:error, msg} ->
      resp(conn, 500, "Something went wrong: #{inspect(msg)}")
    end
  end

  def booking_reschedule_confirmed(conn, _params) do
    send_resp(conn, 200, "Booking rescheduled")
  end

  def booking_reschedule_failed(conn, _params) do
    send_resp(conn, 200, "Booking reschedule failed")
  end
end
