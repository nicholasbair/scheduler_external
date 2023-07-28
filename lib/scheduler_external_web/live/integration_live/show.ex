defmodule SchedulerExternalWeb.IntegrationLive.Show do
  use SchedulerExternalWeb, :live_view

  alias SchedulerExternal.Integrations
  alias SchedulerExternal.Integrations.Provider

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:integration, Integrations.get_integration!(id))}
  end

  @impl true
  def handle_event("start_reauth", %{"id" => id}, socket) do
    integration = Integrations.get_integration_for_user!(socket.assigns.current_user.id, id)
    {:ok, url} = Provider.auth_url(integration.email_address)

    {:noreply, redirect(socket, external: url)}
  end

  defp page_title(:show), do: "Show Integration"
  defp page_title(:edit), do: "Edit Integration"
end
