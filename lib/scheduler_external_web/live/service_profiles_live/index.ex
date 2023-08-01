defmodule SchedulerExternalWeb.ServiceProfileLive.Index do
  use SchedulerExternalWeb, :live_view

  alias SchedulerExternal.Profiles

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :profiles, Profiles.list_public_profiles())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Services")
    |> assign(:profile, nil)
  end
end
