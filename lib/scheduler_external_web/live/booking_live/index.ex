defmodule SchedulerExternalWeb.BookingLive.Index do
  use SchedulerExternalWeb, :live_view

  alias SchedulerExternal.Bookings
  alias SchedulerExternal.Bookings.Booking

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
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

  defp apply_action(socket, :new, params) do
    socket
    |> assign(:page_title, "New Booking")
    |> assign(:booking, params_to_booking(params))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Bookings")
    |> assign(:booking, nil)
  end

  @impl true
  # TODO: this is not used
  def handle_info({SchedulerExternalWeb.BookingLive.FormComponent, {:saved, booking}}, socket) do
    {:noreply, redirect(socket, to: "/bookings/payment?booking_id=#{booking.id}")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    booking = Bookings.get_booking!(id)
    {:ok, _} = Bookings.delete_booking(booking)

    {:noreply, stream_delete(socket, :bookings, booking)}
  end

  defp params_to_booking(params) do
    %Booking{
      start_time: String.to_integer(params["start_time"]),
      end_time: String.to_integer(params["end_time"]),
      page_id: params["page_id"],
    }
  end
end
