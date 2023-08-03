defmodule SchedulerExternalWeb.BookingController do
  use SchedulerExternalWeb, :controller

  require Logger

  def payment(conn, params) do
    Logger.info("payment: #{inspect(params)}")

    booking = SchedulerExternal.Bookings.get_booking!(params["booking_id"])
    page = SchedulerExternal.Pages.get_page!(booking.page_id)
    integration = SchedulerExternal.Integrations.get_integration!(page.integration_id)
    url = SchedulerExternalWeb.Endpoint.url()

    params = %{
      line_items: [
        %{
          price_data: %{
            currency: "usd",
            unit_amount: page.cost * 100, # 100 == $1.00
            product_data: %{
              name: page.title,
            },
          },
          quantity: 1,
        },
      ],
      mode: "payment",
      success_url: url <> "/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: url <> "/cancel?session_id={CHECKOUT_SESSION_ID}"
    }

    event_params = %{
      title: page.title,
      location: page.location,
      start_time: booking.start_time,
      end_time: booking.end_time,
      email: booking.email_address,
      calendar_id: page.calendar_id,
    }

    with {:ok, %{id: session_id, url: session_url} = _session} <- Stripe.Session.create(params),
      {:ok, event} <- SchedulerExternal.Integrations.Provider.create_event(integration, event_params),
        {:ok, _booking} <- SchedulerExternal.Bookings.update_booking(booking, %{session_id: session_id, vendor_id: event.id, vendor_job_id: event.job_status_id}) do
          conn
          |> put_status(303)
          |> redirect(external: session_url)
      end

    conn
    |> put_status(500)
  end

  def success(conn, params) do
    Logger.info("success: #{inspect(params)}")
    # TODO: update booking as paid

    render(conn, "success.html")
  end

  def cancel(conn, params) do
    Logger.info("cancel: #{inspect(params)}")
    # TODO: update booking as unpaid?  Or wait for TTL to expire?
    render(conn, "cancel.html")
  end

end
