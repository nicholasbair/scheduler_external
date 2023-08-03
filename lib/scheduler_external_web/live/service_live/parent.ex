defmodule SchedulerExternalWeb.ServiceLive.Parent do
  use SchedulerExternalWeb, :live_view

  require Logger

  alias SchedulerExternal.Pages
  alias SchedulerExternal.Integrations.Provider

  @impl true
  def render(assigns) do
    SchedulerExternalWeb.ServiceLive.Iframe.render(assigns)
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _, socket) do
    # TODO: make sure page is valid, e.g. integration is valid
    page = Pages.get_page_by_slug!(slug)

    {:noreply, apply_action(socket, :new, page)}
  end

  @impl true
  def handle_info({:callback, params}, socket) do
    {:noreply, push_navigate(socket, to: "/bookings/new?" <> URI.encode_query(params))}
  end

  defp apply_action(socket, :new, page) do
    socket
    |> assign(:page_title, page_title(socket.assigns.live_action))
    |> assign(:url, Provider.get_page_url(page.slug) <> "?" <> add_state(page))
  end

  defp page_title(:show), do: "Show Service"

  defp add_state(%{id: id} = _page) do
    %{page_id: id, pid: get_pid()}
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
