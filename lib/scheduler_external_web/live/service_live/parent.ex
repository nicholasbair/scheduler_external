defmodule SchedulerExternalWeb.ServiceLive.Parent do
  use SchedulerExternalWeb, :live_view

  require Logger

  alias SchedulerExternal.{
    Pages,
    Bookings,
    Integrations.Provider,
    Integrations.VendorJobs
  }

  @impl true
  def render(assigns) do
    SchedulerExternalWeb.ServiceLive.Iframe.render(assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"slug" => slug, "booking_id" => booking_id, "reschedule" => "true"}, _, socket) do
    # TODO: make sure page is valid, e.g. integration is valid
    page = Pages.get_page_by_slug!(slug)

    {:noreply, apply_action(socket, :reschedule, {page, booking_id})}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _, socket) do
    # TODO: make sure page is valid, e.g. integration is valid
    page = Pages.get_page_by_slug!(slug)

    {:noreply, apply_action(socket, :new, page)}
  end

  @impl true
  def handle_info({:callback, %{"reschedule" => "true"} = params}, socket) do
    with {:ok, booking} <- Bookings.get_booking(params["booking_id"]),
      {:ok, event} <- Provider.reschedule_event(booking.page.integration, booking, params["start_time"], params["end_time"]),
      {:ok, _} <- VendorJobs.create_vendor_job(%{vendor_id: event.job_status_id, vendor_object_id: event.id, action: :update}),
      {:ok, _} <- Bookings.update_booking(booking, %{start_time: params["start_time"], end_time: params["end_time"]}) do
        {:noreply, push_navigate(socket, to: "/bookings/#{params["booking_id"]}/reschedule-confirmed")}
    else {:error, reason} ->
      Logger.info("Failed to reschedule booking: #{inspect(reason)}")
      {:noreply, push_navigate(socket, to: "/bookings/#{params["booking_id"]}/reschedule-failed")}
    end
  end

  def handle_info({:callback, params}, socket) do
    {:noreply, push_navigate(socket, to: "/bookings/new?" <> URI.encode_query(params))}
  end

  defp apply_action(socket, :new, page) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:url, Provider.get_page_url(page.slug) <> "?" <> add_state([page_id: page.id]))
  end

  defp apply_action(socket, :reschedule, {page, booking_id}) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:url, Provider.get_page_url(page.slug) <> "?" <> add_state([page_id: page.id, booking_id: booking_id, reschedule: true]))
  end

  defp page_title(:show), do: "Show Service"
  defp page_title(:reschedule), do: "Reschedule Service"

  defp add_state(args) do
    args
    |> Enum.reduce(%{}, fn {key, value}, acc -> Map.put(acc, key, value) end)
    |> Map.put(:pid, get_pid())
    |> URI.encode_query()
  end

  defp get_pid() do
    self()
    |> :erlang.pid_to_list()
    |> List.delete_at(0)
    |> List.delete_at(-1)
    |> to_string()
  end
end
