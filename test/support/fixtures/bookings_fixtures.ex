defmodule SchedulerExternal.BookingsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SchedulerExternal.Bookings` context.
  """

  @doc """
  Generate a booking.
  """
  def booking_fixture(attrs \\ %{}) do
    {:ok, booking} =
      attrs
      |> Enum.into(%{
        email_address: "some email_address",
        end_time: 42,
        first_name: "some first_name",
        last_name: "some last_name",
        paid: true,
        start_time: 42,
        vendor_confirmed: true,
        vendor_id: "some vendor_id",
        vendor_job_id: "some vendor_job_id"
      })
      |> SchedulerExternal.Bookings.create_booking()

    booking
  end
end
