defmodule SchedulerExternal.IntegrationsTest do
  use SchedulerExternal.DataCase

  alias SchedulerExternal.Integrations

  describe "integrations" do
    alias SchedulerExternal.Integrations.Integration

    import SchedulerExternal.IntegrationsFixtures

    @invalid_attrs %{email_address: nil, invalid_since: nil, token: nil, valid: nil, vendor_id: nil}

    test "list_integrations/0 returns all integrations" do
      integration = integration_fixture()
      assert Integrations.list_integrations() == [integration]
    end

    test "get_integration!/1 returns the integration with given id" do
      integration = integration_fixture()
      assert Integrations.get_integration!(integration.id) == integration
    end

    test "create_integration/1 with valid data creates a integration" do
      valid_attrs = %{email_address: "some email_address", invalid_since: ~U[2023-07-25 20:57:00Z], token: "some token", valid: true, vendor_id: "some vendor_id"}

      assert {:ok, %Integration{} = integration} = Integrations.create_integration(valid_attrs)
      assert integration.email_address == "some email_address"
      assert integration.invalid_since == ~U[2023-07-25 20:57:00Z]
      assert integration.token == "some token"
      assert integration.valid == true
      assert integration.vendor_id == "some vendor_id"
    end

    test "create_integration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Integrations.create_integration(@invalid_attrs)
    end

    test "update_integration/2 with valid data updates the integration" do
      integration = integration_fixture()
      update_attrs = %{email_address: "some updated email_address", invalid_since: ~U[2023-07-26 20:57:00Z], token: "some updated token", valid: false, vendor_id: "some updated vendor_id"}

      assert {:ok, %Integration{} = integration} = Integrations.update_integration(integration, update_attrs)
      assert integration.email_address == "some updated email_address"
      assert integration.invalid_since == ~U[2023-07-26 20:57:00Z]
      assert integration.token == "some updated token"
      assert integration.valid == false
      assert integration.vendor_id == "some updated vendor_id"
    end

    test "update_integration/2 with invalid data returns error changeset" do
      integration = integration_fixture()
      assert {:error, %Ecto.Changeset{}} = Integrations.update_integration(integration, @invalid_attrs)
      assert integration == Integrations.get_integration!(integration.id)
    end

    test "delete_integration/1 deletes the integration" do
      integration = integration_fixture()
      assert {:ok, %Integration{}} = Integrations.delete_integration(integration)
      assert_raise Ecto.NoResultsError, fn -> Integrations.get_integration!(integration.id) end
    end

    test "change_integration/1 returns a integration changeset" do
      integration = integration_fixture()
      assert %Ecto.Changeset{} = Integrations.change_integration(integration)
    end
  end
end
