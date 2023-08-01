defmodule SchedulerExternalWeb.ServiceLive.Show do
  use SchedulerExternalWeb, :live_view

  alias SchedulerExternal.Pages
  alias SchedulerExternal.Integrations.Provider

  @impl true
  def render(assigns) do
    ~H"""
      <iframe src={@url} class="w-full h-full" frameborder="0"></iframe>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _, socket) do
    # TODO: make sure page is valid, e.g. integration is valid
    # TODO: insert booking ID query param that matches temp booking
    page = Pages.get_page_by_slug!(slug)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:url, Provider.get_page_url(page.slug) <> "?booking_id=123")}
  end

  defp page_title(:show), do: "Show Service"
end
