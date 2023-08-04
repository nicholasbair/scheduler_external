defmodule SchedulerExternalWeb.IntegrationController do
  use SchedulerExternalWeb, :controller
  alias SchedulerExternal.Integrations.Provider

  # Note - ideally should be using and checking the state param on the callback
  def callback(conn, params) do
    with {:ok, account} <- Provider.exchange_code_for_token(params["code"]),
        {:ok, integration} <- SchedulerExternal.Integrations.upsert_integration(%{"name" => "Calendar", "valid?" => true, "user_id" => conn.assigns.current_user.id, "token" => account.access_token, "vendor_id" => account.account_id, "email_address" => account.email_address, "invalid_since" => nil}) do

      # If there is only one valid token, SDK will return an error from the Nylas API
      # Calling revoke here will ensure there is only ever one valid token
      Provider.revoke_all_except(integration)

      # Tell the Nylas scheduler about the new access token
      Provider.get_pages(integration)

      conn
      |> put_flash(:info, "Authentication successful!")
      |> redirect(to: ~p"/integrations")
    else
      {:error, _} ->
        conn
        |> put_flash(:error, "Authentication unsuccessful.")
        |> redirect(to: ~p"/integrations")
    end
  end
end
