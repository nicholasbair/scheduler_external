defmodule SchedulerExternalWeb.IntegrationLive.Index do
  use SchedulerExternalWeb, :live_view

  alias SchedulerExternal.Integrations.Provider
  alias SchedulerExternal.Integrations
  alias SchedulerExternal.Integrations.Integration

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :integrations, Integrations.list_integrations())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Integration")
    |> assign(:integration, Integrations.get_integration!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Integration")
    |> assign(:integration, %Integration{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Integrations")
    |> assign(:integration, nil)
  end

  @impl true
  def handle_info({SchedulerExternalWeb.IntegrationLive.FormComponent, {:saved, integration}}, socket) do
    {:noreply, stream_insert(socket, :integrations, integration)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    integration = Integrations.get_integration!(id)
    {:ok, _} = Integrations.delete_integration(integration)

    {:noreply, stream_delete(socket, :integrations, integration)}
  end

  @impl true
  def handle_event("start_auth", _params, socket) do
    {:ok, url} = Provider.auth_url()
    {:noreply, redirect(socket, external: url)}
  end

  @impl true
  def handle_event("start_reauth", %{"id" => id}, socket) do
    integration = Integrations.get_integration_for_user!(socket.assigns.current_user.id, id)
    {:ok, url} = Provider.auth_url(integration.email_address)

    {:noreply, redirect(socket, external: url)}
  end
end
