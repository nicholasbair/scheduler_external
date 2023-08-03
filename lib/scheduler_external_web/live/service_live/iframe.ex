defmodule SchedulerExternalWeb.ServiceLive.Iframe do
  use SchedulerExternalWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
      <iframe id="iframe" src={@url} class="w-full h-full" frameborder="0"></iframe>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
