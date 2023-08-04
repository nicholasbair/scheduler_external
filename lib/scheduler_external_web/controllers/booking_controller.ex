defmodule SchedulerExternalWeb.BookingController do
  use SchedulerExternalWeb, :controller

  require Logger

  def payment(conn, params) do
    Logger.info("payment: #{inspect(params)}")

    booking = SchedulerExternal.Bookings.get_booking!(params["booking_id"])
    page = SchedulerExternal.Pages.get_page!(booking.page_id)
    url = SchedulerExternalWeb.Endpoint.url()

    stripe_params = %{
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
      success_url: url <> "/bookings/payment/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: url <> "/bookings/payment/cancel?session_id={CHECKOUT_SESSION_ID}"
    }

    with {:ok, %{id: session_id, url: session_url} = _session} <- Stripe.Session.create(stripe_params),
        {:ok, _booking} <- SchedulerExternal.Bookings.update_booking(booking, %{payment_session_id: session_id}) do
          conn
          |> put_status(303)
          |> redirect(external: session_url)
      end

    conn
    |> put_status(500)
  end

  def success(conn, params) do
    with {:ok, booking} <- SchedulerExternal.Bookings.get_booking_by_payment_session(params["session_id"]),
      {:ok, page} <- SchedulerExternal.Pages.get_page(booking.page_id),
        {:ok, integration} <- SchedulerExternal.Integrations.get_integration(page.integration_id),
          {:ok, event} <- SchedulerExternal.Integrations.Provider.confirm_event(integration, booking, page) do
            SchedulerExternal.Bookings.update_booking(booking, %{paid: true, vendor_job_id: event.job_status_id})
    end

    render(conn, "success.html")
  end

  def cancel(conn, _params) do
    # TODO: delete booking, delete pending event on Nylas

    render(conn, "cancel.html")
  end

end
