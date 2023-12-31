defmodule SchedulerExternal.Integrations.Worker do
  @moduledoc """
  The Integrations worker.

  This worker is responsible for:
  - Checking for stale integrations and deleting the associated Nylas account if the integration is stale (e.g. the user has not re-authenicated one week after the integration was marked as invalid)
  - Marking integrations as invalid if a stopped or invalid webhook is received from Nylas
  """

  require Logger

  alias SchedulerExternal.{
    Integrations,
    Integrations.Provider
  }

  use Oban.Worker,
    queue: :integrations,
    max_attempts: 3

  @one_week 7 * 60 * 60 * 24

  @impl true
  def perform(%{args: %{"task" => "check_stale_integrations"}}) do
    check_stale_integrations()
  end

  def perform(%{args: %{"vendor_id" => id, "task" => "mark_integration_invalid"}}) do
    with {:ok, integration} <- Integrations.get_integration_by_vendor_id(id),
      {:ok, _} <- Integrations.update_integration(integration, %{integration | valid?: false, invalid_since: DateTime.utc_now()}) do
        Logger.info("Successfully marked integration with id #{integration.id} as invalid")
      end

    :ok
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
