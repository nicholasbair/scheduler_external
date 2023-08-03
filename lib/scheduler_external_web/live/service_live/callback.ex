defmodule SchedulerExternalWeb.ServiceLive.Callback do
  use SchedulerExternalWeb, :live_view

  import IEx.Helpers, only: [pid: 1]

  @impl true
  def render(assigns) do
    ~H"""
      <div></div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _, socket) do
    send(pid(params["pid"]), {:callback, params})
    {:noreply, socket}
  end
end
