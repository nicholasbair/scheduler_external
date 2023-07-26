defmodule SchedulerExternal.IntegrationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SchedulerExternal.Integrations` context.
  """

  @doc """
  Generate a integration.
  """
  def integration_fixture(attrs \\ %{}) do
    {:ok, integration} =
      attrs
      |> Enum.into(%{
        email_address: "some email_address",
        invalid_since: ~U[2023-07-25 20:57:00Z],
        token: "some token",
        valid: true,
        vendor_id: "some vendor_id"
      })
      |> SchedulerExternal.Integrations.create_integration()

    integration
  end
end
