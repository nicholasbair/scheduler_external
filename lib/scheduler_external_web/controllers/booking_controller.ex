defmodule SchedulerExternalWeb.BookingController do
  use SchedulerExternalWeb, :controller

  require Logger

  def start(conn, params) do
    Logger.info("BookingController.start")
    Logger.info("params: #{inspect(params)}")

    # Booking
      # page_id
      # vendor_id for event on Nylas
      # start and end time
      # paid?
      # need to store the job status ID from Nylas
      # confirmed (if the job was successful)
      # First/last name
      # Email address

    # TODO:
      # 1. Create blocking event => track job status
      # 2. Redirect user to payment page
      # 3. On payment success, create event and invite them
    # send_resp(conn, 200, "OK")

    redirect(conn, to: "/bookings/new")

  end
end
