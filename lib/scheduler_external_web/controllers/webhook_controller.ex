defmodule SchedulerExternalWeb.WebhookController do
  use SchedulerExternalWeb, :controller

  def challenge(conn, params) do
    text(conn, params["challenge"])
  end

  # Note:
    # Not verifying webhook signature, Phoenix doesn't expose the raw payload in the controller,
    # there is a hack to get this value but avoiding for simplicity
    # ref: https://github.com/phoenixframework/phoenix/issues/459#issuecomment-889050289

  def receive_webhook(conn, %{"deltas" => [%{"type" => "job.failed"} = head | _tail]} = _params) do
    head
    |> SchedulerExternal.Jobs.Worker.new()
    |> Oban.insert!()

    send_resp(conn, 200, "")
  end

  def receive_webhook(conn, %{"deltas" => [%{"type" => type, "object_data" => %{"id" => id}} | _tail]} = _params) when type in ["account.invalid", "account.stopped"] do
    %{"vendor_id" => id, "task" => "mark_integration_invalid"}
    |> SchedulerExternal.Integrations.Worker.new()
    |> Oban.insert!()

    send_resp(conn, 200, "")
  end
end
