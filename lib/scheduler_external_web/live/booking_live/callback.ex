defmodule SchedulerExternalWeb.BookingLive.Callback do
  use SchedulerExternalWeb, :live_view

#   alias ExNylas.Scheduler.Booking

  require Logger

  @impl true
  def render(assigns) do
    ~H"""
      <div></div>
    """
  end

  # TODO: try removing the entire HTML page that the iframe is in
  # TODO: try handling the iframe in a standard HTML page

  @impl true
  def mount(params, session, socket) do
    # {:ok, socket |> push_event("iframe-callback", %{booking_id: "123"})}
    {:ok, socket}
  end

  @impl true
  def handle_params(params, url, socket) do

    # TODO: do some stuff with the params

    Logger.info("==================================>>>>>> sending message to parent #{inspect socket.parent_pid}")
    send(socket.parent_pid, {:hello, "world"})

    # booking = %Booking{}
    # notify_parent({:callback, booking})
    # {:noreply, socket}

    # Logger.info("==================================>>>>>> pushing event")

    # {:noreply,
      # socket
      # |> push_event("iframe-callback", %{booking_id: "123"})}

  end

#   # defp apply_action(socket, :edit, %{"id" => id}) do
#   #   socket
#   #   |> assign(:page_title, "Edit Booking")
#   #   |> assign(:booking, Bookings.get_booking!(id))
#   # end

#   @impl true
#   def handle_info({SchedulerExternalWeb.BookingLive.FormComponent, {:saved, booking}}, socket) do
#     {:noreply, stream_insert(socket, :bookings, booking)}
#   end

#   defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

end
