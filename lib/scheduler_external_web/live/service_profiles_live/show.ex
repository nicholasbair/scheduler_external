defmodule SchedulerExternalWeb.ServiceProfileLive.Show do
  use SchedulerExternalWeb, :live_view

  alias SchedulerExternal.Profiles

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _, socket) do
    profile = Profiles.get_profile_by_slug!(slug)

    pages =
      profile.pages
      |> Enum.map(fn p -> {p.id, p} end)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:profile, profile)
     |> assign(:pages, pages)}
  end

  defp page_title(:show), do: "Show Service"
end
