defmodule SchedulerExternalWeb.BookingLive.Index do
  use SchedulerExternalWeb, :live_view

  alias SchedulerExternal.Bookings
  alias SchedulerExternal.Bookings.Booking

  @impl true
  def mount(_params, _session, socket) do
    # TODO: only show bookings for a given page
    {:ok, stream(socket, :bookings, Bookings.list_bookings())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Booking")
    |> assign(:booking, Bookings.get_booking!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Booking")
    |> assign(:booking, %Booking{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Bookings")
    |> assign(:booking, nil)
  end

  @impl true
  def handle_info({SchedulerExternalWeb.BookingLive.FormComponent, {:saved, booking}}, socket) do
    {:noreply, stream_insert(socket, :bookings, booking)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    booking = Bookings.get_booking!(id)
    {:ok, _} = Bookings.delete_booking(booking)

    {:noreply, stream_delete(socket, :bookings, booking)}
  end
end
