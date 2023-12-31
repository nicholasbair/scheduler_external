defmodule SchedulerExternalWeb.BookingLiveTest do
  use SchedulerExternalWeb.ConnCase

  import Phoenix.LiveViewTest
  import SchedulerExternal.BookingsFixtures

  @create_attrs %{email_address: "some email_address", end_time: 42, first_name: "some first_name", last_name: "some last_name", paid: true, start_time: 42, vendor_confirmed: true, vendor_id: "some vendor_id", vendor_job_id: "some vendor_job_id"}
  @update_attrs %{email_address: "some updated email_address", end_time: 43, first_name: "some updated first_name", last_name: "some updated last_name", paid: false, start_time: 43, vendor_confirmed: false, vendor_id: "some updated vendor_id", vendor_job_id: "some updated vendor_job_id"}
  @invalid_attrs %{email_address: nil, end_time: nil, first_name: nil, last_name: nil, paid: false, start_time: nil, vendor_confirmed: false, vendor_id: nil, vendor_job_id: nil}

  defp create_booking(_) do
    booking = booking_fixture()
    %{booking: booking}
  end

  describe "Index" do
    setup [:create_booking]

    test "lists all bookings", %{conn: conn, booking: booking} do
      {:ok, _index_live, html} = live(conn, ~p"/bookings")

      assert html =~ "Listing Bookings"
      assert html =~ booking.email_address
    end

    test "saves new booking", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/bookings")

      assert index_live |> element("a", "New Booking") |> render_click() =~
               "New Booking"

      assert_patch(index_live, ~p"/bookings/new")

      assert index_live
             |> form("#booking-form", booking: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#booking-form", booking: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/bookings")

      html = render(index_live)
      assert html =~ "Booking created successfully"
      assert html =~ "some email_address"
    end

    test "updates booking in listing", %{conn: conn, booking: booking} do
      {:ok, index_live, _html} = live(conn, ~p"/bookings")

      assert index_live |> element("#bookings-#{booking.id} a", "Edit") |> render_click() =~
               "Edit Booking"

      assert_patch(index_live, ~p"/bookings/#{booking}/edit")

      assert index_live
             |> form("#booking-form", booking: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#booking-form", booking: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/bookings")

      html = render(index_live)
      assert html =~ "Booking updated successfully"
      assert html =~ "some updated email_address"
    end

    test "deletes booking in listing", %{conn: conn, booking: booking} do
      {:ok, index_live, _html} = live(conn, ~p"/bookings")

      assert index_live |> element("#bookings-#{booking.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#bookings-#{booking.id}")
    end
  end

  describe "Show" do
    setup [:create_booking]

    test "displays booking", %{conn: conn, booking: booking} do
      {:ok, _show_live, html} = live(conn, ~p"/bookings/#{booking}")

      assert html =~ "Show Booking"
      assert html =~ booking.email_address
    end

    test "updates booking within modal", %{conn: conn, booking: booking} do
      {:ok, show_live, _html} = live(conn, ~p"/bookings/#{booking}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Booking"

      assert_patch(show_live, ~p"/bookings/#{booking}/show/edit")

      assert show_live
             |> form("#booking-form", booking: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#booking-form", booking: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/bookings/#{booking}")

      html = render(show_live)
      assert html =~ "Booking updated successfully"
      assert html =~ "some updated email_address"
    end
  end
end
