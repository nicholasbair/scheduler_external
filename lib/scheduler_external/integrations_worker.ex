defmodule SchedulerExternal.Integrations.Worker do
  require Logger

  alias SchedulerExternal.Integrations
  alias SchedulerExternal.Provider

  use Oban.Worker,
    queue: :integrations,
    max_attempts: 3

  @one_week 7 * 60 * 60 * 24

  @impl true
  def perform(%{args: %{"task" => "check_stale_integrations"}}) do
    check_stale_integrations()
  end

  defp check_stale_integrations() do
    Logger.info("Checking for stale integrations")

    with {:ok, integrations} <- Integrations.list_invalid_integrations() do
      Enum.each(integrations, &check_integration/1)
    end

    :ok
  end

  defp check_integration(integration) do
    with true <- stale?(integration),
      {:ok, _success} <- Provider.delete_integration(integration.vendor_id),
      {:ok, _integration} <- Integrations.delete_integration(integration.id) do
        Logger.info("Successfully deleted stale integration with id #{integration.id}")
    end
  end

  defp stale?(integration) do
    DateTime.diff(DateTime.utc_now(), integration.invalid_since) > @one_week
  end
end
