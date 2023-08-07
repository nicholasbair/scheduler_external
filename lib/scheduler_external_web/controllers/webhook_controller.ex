defmodule SchedulerExternalWeb.WebhookController do
  use SchedulerExternalWeb, :controller

  alias SchedulerExternal.{
    Integrations,
    Jobs
  }

  def challenge(conn, params) do
    text(conn, params["challenge"])
  end

  # Note:
    # Not verifying webhook signature, Phoenix doesn't expose the raw payload in the controller,
    # there is a way to handle this upstream but avoiding for simplicity
    # ref: https://github.com/phoenixframework/phoenix/issues/459#issuecomment-889050289

  def receive_webhook(conn, %{"deltas" => [%{"type" => type} = head | _tail]} = _params) when type in ["job.successful", "job.failed"] do
    head
    |> Jobs.Worker.new()
    |> Oban.insert!()

    send_resp(conn, 200, "")
  end

  def receive_webhook(conn, %{"deltas" => [%{"type" => type, "object_data" => %{"id" => id}} | _tail]} = _params) when type in ["account.invalid", "account.stopped"] do
    %{"vendor_id" => id, "task" => "mark_integration_invalid"}
    |> Integrations.Worker.new()
    |> Oban.insert!()

    send_resp(conn, 200, "")
  end
end
