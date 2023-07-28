defmodule SchedulerExternal.Integrations.Provider do
  @moduledoc """
  Wrapper around ExNylas SDK to provide convenience functions for interacting with the Nylas API.
  """

  @doc """
  Returns the auth URL for the Nylas integration.

  ## Examples

      iex> auth_url()
      {:ok, "https://api.nylas.com/oauth/authorize?client_id=1234&redirect_uri=https://example.com&response_type=code&scopes=calendar&login_hint=some@email.com"}
  """
  def auth_url(email \\ nil) do
    connection()
    |> ExNylas.Authentication.Hosted.get_auth_url(
      %{
        redirect_uri: Application.get_env(:scheduler_external, :nylas_redirect_uri),
        scopes: ["calendar"],
        response_type: "code",
        login_hint: email
      }
    )
  end

  @doc """
  Returns the connection for the Nylas integration.

  ## Examples

      iex> connection()
      %ExNylas.Connection{
        api_server: "https://api.nylas.com",
        client_id: "1234",
        client_secret: "5678"
      }
  """
  def connection() do
    %ExNylas.Connection{
      api_server: Application.get_env(:scheduler_external, :nylas_api_server),
      client_id: Application.get_env(:scheduler_external, :nylas_client_id),
      client_secret: Application.get_env(:scheduler_external, :nylas_client_secret),
    }
  end

  @doc """
  Returns the connection for the Nylas integration with the given token.

  ## Examples

      iex> connection_with_token("abcd")
      %ExNylas.Connection{
          api_server: "https://api.nylas.com",
          client_id: "1234",
          client_secret: "5678",
          access_token: "abcd"
        }
  """
  def connection_with_token(%{token: token} = _integration) do
    %ExNylas.Connection{
      api_server: Application.get_env(:scheduler_external, :nylas_api_server),
      access_token: token
    }
  end

  @doc """
  Returns the Nylas connected account.

  ## Examples

      iex> exchange_code_for_token("abcd")
      {:ok, %ExNylas.Account{
        account_id: "abcd",
        access_token: "efgh",
        email_address: "nick@example.com"
      }}
  """
  def exchange_code_for_token(code) do
    connection()
    |> ExNylas.Authentication.Hosted.exchange_code_for_token(code)
  end

  @doc """
  Revokes all tokens except the given token.

  ## Examples

      iex> revoke_all_except(integration)
      {:ok, %{success: true}}

      iex> revoke_all_except(integration)
      {:error, reason}
  """
  def revoke_all_except(%{token: token, vendor_id: id} = _integration) do
    connection()
    |> ExNylas.Authentication.revoke_all(id, token)
  end

  @doc """
  Revokes all tokens.

  ## Examples

      iex> revoke_all(integration)
      {:ok, %{success: true}}

      iex> revoke_all(integration)
      {:error, reason}
  """
  def revoke_all(%{vendor_id: id} = _integration) do
    connection()
    |> ExNylas.Authentication.revoke_all(id)
  end

  @doc """
  Revoke and downgrade a given integration.

  ## Examples

      iex> delete_integration(integration)
      {:ok, %{success: true}}

      iex> delete_integration(integration)
      {:error, reason}
  """
  def delete_integration(%{vendor_id: id} = integration) do
    integration
    |> revoke_all()

    connection()
    |> ExNylas.ManagementAccounts.delete(id)
  end

  @doc """
  Create a scheduler page.

  ## Examples
    iex> create_page(integration, %{"title" => "My Event", "duration" => 60, "location" => "My Office"})
    {:ok, %ExNylas.Scheduler.Page{
      access_tokens: ["abcd"],
      event: %{
        title: "My Event",
        duration: 60,
        location: "My Office"
      },
      name: "My Event"
    }}
  """
  # TODO: prob need to collect more stuff here, e.g. timezone
  def create_page(integration, attrs \\ %{}) do

    integration
    |> connection_with_token()
    |> ExNylas.Scheduler.create(page_config(integration.token, attrs["title"], attrs["duration"], attrs["location"]))
  end

  @doc """
  Update a scheduler page.

  ## Examples
    iex> update_page(integration, %{"title" => "My Event", "duration" => 60, "location" => "My Office"})
    {:ok, %ExNylas.Scheduler.Page{
      access_tokens: ["abcd"],
      event: %{
        title: "My Event",
        duration: 60,
        location: "My Office"
      },
      name: "My Event"
    }}
  """
  def update_page(integration, attrs \\ %{}) do
    integration
    |> connection_with_token()
    |> ExNylas.Scheduler.update(page_config(integration.token, attrs["title"], attrs["duration"], attrs["location"]), attrs["vendor_id"])
  end

  defp page_config(token, title, duration, location) do
    %{
      access_tokens: [token],
      appearance: %{
        thank_you_redirect: "http://localhost:4000/bookings/payment"
      },
      config: %{
        event: %{
          title: title,
          duration: duration,
          location: location,
        },
        booking: %{
          confirmation_method: "external",
        }
      },
      name: title,
    }
  end
end
