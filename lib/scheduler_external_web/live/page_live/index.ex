defmodule SchedulerExternalWeb.PageLive.Index do
  use SchedulerExternalWeb, :live_view

  alias SchedulerExternal.Pages
  alias SchedulerExternal.Pages.Page
  alias SchedulerExternal.Integrations
  alias SchedulerExternal.Profiles

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :pages, Pages.list_pages(socket.assigns.current_user.id))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Page")
    |> assign(:page, Pages.get_page!(id))
  end

  defp apply_action(socket, :new, _params) do
    # TODO: if no valid integrations for user, show error
    integrations =
      Integrations.list_valid_integrations_for_user(socket.assigns.current_user.id)
      |> Enum.map(fn integration -> {integration.email_address, integration.id} end)

    profiles =
      Profiles.list_profiles_by_user(socket.assigns.current_user.id)
      |> Enum.map(fn profile -> {profile.name, profile.id} end)

    # Setting integrations independently of page in assign/3 doesn't work
    # Bit of a hack, passing integrations on page map
    page =
      %Page{}
      |> Map.put(:user_id, socket.assigns.current_user.id)
      |> Map.put(:integrations, integrations)
      |> Map.put(:profiles, profiles)

    socket
    |> assign(:page_title, "New Page")
    |> assign(:page, page)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Pages")
    |> assign(:page, nil)
  end

  @impl true
  def handle_info({SchedulerExternalWeb.PageLive.FormComponent, {:saved, page}}, socket) do
    {:noreply, stream_insert(socket, :pages, page)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    page = Pages.get_page!(id)
    {:ok, _} = Pages.delete_page(page)

    {:noreply, stream_delete(socket, :pages, page)}
  end
end
