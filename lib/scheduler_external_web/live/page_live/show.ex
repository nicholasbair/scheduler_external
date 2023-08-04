defmodule SchedulerExternalWeb.PageLive.Show do
  use SchedulerExternalWeb, :live_view

  alias SchedulerExternal.Pages

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    page = Pages.get_page!(id)
    url = SchedulerExternal.Pages.slug_to_url(page)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:page, Map.put(page, :url, url))}
  end

  defp page_title(:show), do: "Show Page"
  defp page_title(:edit), do: "Edit Page"
end
