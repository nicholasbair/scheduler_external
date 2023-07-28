defmodule SchedulerExternalWeb.BookingController do
  use SchedulerExternalWeb, :controller

  def new(conn, _params) do
    # TODO:
      # 1. Create blocking event => track job status
      # 2. Redirect user to payment page
      # 3. On payment success, create event and invite them
    send_resp(conn, 200, "OK")
  end
end
