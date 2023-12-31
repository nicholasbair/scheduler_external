defmodule SchedulerExternalWeb.BookingLive.FormComponent do
  require Logger
  use SchedulerExternalWeb, :live_component

  alias SchedulerExternal.Bookings

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage booking records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="booking-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:start_time]} type="hidden" />
        <.input field={@form[:end_time]} type="hidden" />
        <.input field={@form[:page_id]} type="hidden" />
        <.input field={@form[:calendar_id]} type="hidden" />
        <.input field={@form[:first_name]} type="text" label="First name" />
        <.input field={@form[:last_name]} type="text" label="Last name" />
        <.input field={@form[:email_address]} type="text" label="Email address" />
        <:actions>
          <.button phx-disable-with="Saving...">Continue to payment</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{booking: booking} = assigns, socket) do
    changeset = Bookings.change_booking(booking)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"booking" => booking_params}, socket) do
    changeset =
      socket.assigns.booking
      |> Bookings.change_booking(booking_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"booking" => booking_params}, socket) do
    save_booking(socket, socket.assigns.action, booking_params)
  end

  defp save_booking(socket, :new, booking_params) do
    case Bookings.create_booking_with_ttl(booking_params) do
      {:ok, booking} ->
        notify_parent({:saved, booking})

        {:noreply,
         socket
         |> redirect(to: "/bookings/payment?booking_id=#{booking.id}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
