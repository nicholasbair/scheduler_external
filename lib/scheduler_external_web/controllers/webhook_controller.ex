defmodule SchedulerExternalWeb.WebhookController do
  use SchedulerExternalWeb, :controller

  def challenge(conn, params) do
    text(conn, params["challenge"])
  end

  # Note:
    # Not verifying webhook signature, Phoenix doesn't expose the raw payload in the controller,
    # there is a hack to get this value but avoiding for simplicity
    # ref: https://github.com/phoenixframework/phoenix/issues/459#issuecomment-889050289

  # TODO: need job status webhooks

  def receive_webhook(conn, %{"deltas" => [%{"type" => "contact.created", "object_data" => %{"id" => id, "account_id" => account_id}} | _tail]} = _params) do
    with {:ok, _integration} <- SchedulerExternal.Integrations.get_integration_by_vendor_id(account_id) do
      %{"id" => id, "account_id" => account_id}
      |> Contactifier.Contacts.Worker.new()
      |> Oban.insert!()
    end

    send_resp(conn, 200, "")
  end

  # TODO: move this to a job and mark the scheduler page as invalid as well
  def receive_webhook(conn, %{"deltas" => [%{"type" => type, "object_data" => %{"id" => id}} | _tail]} = _params) when type in ["account.invalid", "account.stopped"] do
    # This is a fairly simple operation, so not using an async job
    with {:ok, integration} <- SchedulerExternal.Integrations.get_integration_by_vendor_id(id) do
      Contactifier.Integrations.update_integration(integration, %{integration | valid?: false, invalid_since: DateTime.utc_now()})
    end

    send_resp(conn, 200, "")
  end
end
