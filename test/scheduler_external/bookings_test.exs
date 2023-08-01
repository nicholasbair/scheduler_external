defmodule SchedulerExternal.BookingsTest do
  use SchedulerExternal.DataCase

  alias SchedulerExternal.Bookings

  describe "bookings" do
    alias SchedulerExternal.Bookings.Booking

    import SchedulerExternal.BookingsFixtures

    @invalid_attrs %{email_address: nil, end_time: nil, first_name: nil, last_name: nil, paid: nil, start_time: nil, vendor_confirmed: nil, vendor_id: nil, vendor_job_id: nil}

    test "list_bookings/0 returns all bookings" do
      booking = booking_fixture()
      assert Bookings.list_bookings() == [booking]
    end

    test "get_booking!/1 returns the booking with given id" do
      booking = booking_fixture()
      assert Bookings.get_booking!(booking.id) == booking
    end

    test "create_booking/1 with valid data creates a booking" do
      valid_attrs = %{email_address: "some email_address", end_time: 42, first_name: "some first_name", last_name: "some last_name", paid: true, start_time: 42, vendor_confirmed: true, vendor_id: "some vendor_id", vendor_job_id: "some vendor_job_id"}

      assert {:ok, %Booking{} = booking} = Bookings.create_booking(valid_attrs)
      assert booking.email_address == "some email_address"
      assert booking.end_time == 42
      assert booking.first_name == "some first_name"
      assert booking.last_name == "some last_name"
      assert booking.paid == true
      assert booking.start_time == 42
      assert booking.vendor_confirmed == true
      assert booking.vendor_id == "some vendor_id"
      assert booking.vendor_job_id == "some vendor_job_id"
    end

    test "create_booking/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Bookings.create_booking(@invalid_attrs)
    end

    test "update_booking/2 with valid data updates the booking" do
      booking = booking_fixture()
      update_attrs = %{email_address: "some updated email_address", end_time: 43, first_name: "some updated first_name", last_name: "some updated last_name", paid: false, start_time: 43, vendor_confirmed: false, vendor_id: "some updated vendor_id", vendor_job_id: "some updated vendor_job_id"}

      assert {:ok, %Booking{} = booking} = Bookings.update_booking(booking, update_attrs)
      assert booking.email_address == "some updated email_address"
      assert booking.end_time == 43
      assert booking.first_name == "some updated first_name"
      assert booking.last_name == "some updated last_name"
      assert booking.paid == false
      assert booking.start_time == 43
      assert booking.vendor_confirmed == false
      assert booking.vendor_id == "some updated vendor_id"
      assert booking.vendor_job_id == "some updated vendor_job_id"
    end

    test "update_booking/2 with invalid data returns error changeset" do
      booking = booking_fixture()
      assert {:error, %Ecto.Changeset{}} = Bookings.update_booking(booking, @invalid_attrs)
      assert booking == Bookings.get_booking!(booking.id)
    end

    test "delete_booking/1 deletes the booking" do
      booking = booking_fixture()
      assert {:ok, %Booking{}} = Bookings.delete_booking(booking)
      assert_raise Ecto.NoResultsError, fn -> Bookings.get_booking!(booking.id) end
    end

    test "change_booking/1 returns a booking changeset" do
      booking = booking_fixture()
      assert %Ecto.Changeset{} = Bookings.change_booking(booking)
    end
  end
end
