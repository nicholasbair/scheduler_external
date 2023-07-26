defmodule SchedulerExternalWeb.IntegrationLiveTest do
  use SchedulerExternalWeb.ConnCase

  import Phoenix.LiveViewTest
  import SchedulerExternal.IntegrationsFixtures

  @create_attrs %{email_address: "some email_address", invalid_since: "2023-07-25T20:57:00Z", token: "some token", valid: true, vendor_id: "some vendor_id"}
  @update_attrs %{email_address: "some updated email_address", invalid_since: "2023-07-26T20:57:00Z", token: "some updated token", valid: false, vendor_id: "some updated vendor_id"}
  @invalid_attrs %{email_address: nil, invalid_since: nil, token: nil, valid: false, vendor_id: nil}

  defp create_integration(_) do
    integration = integration_fixture()
    %{integration: integration}
  end

  describe "Index" do
    setup [:create_integration]

    test "lists all integrations", %{conn: conn, integration: integration} do
      {:ok, _index_live, html} = live(conn, ~p"/integrations")

      assert html =~ "Listing Integrations"
      assert html =~ integration.email_address
    end

    test "saves new integration", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/integrations")

      assert index_live |> element("a", "New Integration") |> render_click() =~
               "New Integration"

      assert_patch(index_live, ~p"/integrations/new")

      assert index_live
             |> form("#integration-form", integration: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#integration-form", integration: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/integrations")

      html = render(index_live)
      assert html =~ "Integration created successfully"
      assert html =~ "some email_address"
    end

    test "updates integration in listing", %{conn: conn, integration: integration} do
      {:ok, index_live, _html} = live(conn, ~p"/integrations")

      assert index_live |> element("#integrations-#{integration.id} a", "Edit") |> render_click() =~
               "Edit Integration"

      assert_patch(index_live, ~p"/integrations/#{integration}/edit")

      assert index_live
             |> form("#integration-form", integration: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#integration-form", integration: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/integrations")

      html = render(index_live)
      assert html =~ "Integration updated successfully"
      assert html =~ "some updated email_address"
    end

    test "deletes integration in listing", %{conn: conn, integration: integration} do
      {:ok, index_live, _html} = live(conn, ~p"/integrations")

      assert index_live |> element("#integrations-#{integration.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#integrations-#{integration.id}")
    end
  end

  describe "Show" do
    setup [:create_integration]

    test "displays integration", %{conn: conn, integration: integration} do
      {:ok, _show_live, html} = live(conn, ~p"/integrations/#{integration}")

      assert html =~ "Show Integration"
      assert html =~ integration.email_address
    end

    test "updates integration within modal", %{conn: conn, integration: integration} do
      {:ok, show_live, _html} = live(conn, ~p"/integrations/#{integration}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Integration"

      assert_patch(show_live, ~p"/integrations/#{integration}/show/edit")

      assert show_live
             |> form("#integration-form", integration: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#integration-form", integration: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/integrations/#{integration}")

      html = render(show_live)
      assert html =~ "Integration updated successfully"
      assert html =~ "some updated email_address"
    end
  end
end
