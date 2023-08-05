defmodule SchedulerExternal.Bookings do
  @moduledoc """
  The Bookings context.
  """

  import Ecto.Query, warn: false
  alias SchedulerExternal.Repo

  alias SchedulerExternal.{
    Bookings,
    Bookings.Booking,
    Integrations,
    Integrations.Provider,
    Pages
  }

  @pending_booking_ttl_minutes 5

  @doc """
  Returns the list of bookings.

  ## Examples

      iex> list_bookings()
      [%Booking{}, ...]

  """
  def list_bookings do
    Repo.all(Booking)
  end

  def list_unpaid_bookings do
    query = from b in Booking,
      where: b.paid == false,
      order_by: [asc: b.inserted_at]
    Repo.all(query)
  end

  @doc """
  Gets a single booking.

  Raises `Ecto.NoResultsError` if the Booking does not exist.

  ## Examples

      iex> get_booking!(123)
      %Booking{}

      iex> get_booking!(456)
      ** (Ecto.NoResultsError)

  """
  def get_booking!(id) do
    Repo.get!(Booking, id)
    |> Repo.preload(:page)
  end

  @doc """
  Gets a single booking by payment session id.

  ## Examples

      iex> get_booking_by_payment_session("123")
      {:ok, %Booking{}}

      iex> get_booking_by_payment_session("456")
      {:error, :not_found}
  """
  def get_booking_by_payment_session(nil), do: Repo.normalize_one(nil)

  def get_booking_by_payment_session(session_id) do
    Repo.get_by(Booking, payment_session_id: session_id)
    |> Repo.preload(page: :integration)
    |> Repo.normalize_one()
  end

  @doc """
  Gets a single booking by job ID.

  ## Examples

      iex> get_booking_by_job("123")
      {:ok, %Booking{}}

      iex> get_booking_by_job("456")
      {:error, :not_found}
  """
  def get_booking_by_job(job_id) do
    Repo.get_by(Booking, vendor_job_id: job_id)
    |> Repo.normalize_one()
  end

  @doc """
  Creates a booking.

  ## Examples

      iex> create_booking(%{field: value})
      {:ok, %Booking{}}

      iex> create_booking(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_booking(attrs \\ %{}) do
    %Booking{}
    |> Booking.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a booking with a TTL, creates event on provider, but does not invite user.

  ## Examples

      iex> create_booking_with_ttl(%{field: value})
      {:ok, %Booking{}}

      iex> create_booking_with_ttl(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_booking_with_ttl(attrs \\ %{}) do
    with {:ok, page} <- Pages.get_page(attrs["page_id"]),
         {:ok, integration} <- Integrations.get_integration(page.integration_id) do

          event_params = %{
            title: page.title,
            location: page.location,
            start_time: attrs["start_time"],
            end_time: attrs["end_time"],
            email: attrs["email_address"],
            calendar_id: page.calendar_id,
          }

          {:ok, event} = Provider.create_pending_event(integration, event_params)

          ttl =
            DateTime.utc_now()
            |> DateTime.add(@pending_booking_ttl_minutes, :minute)

          {:ok, _booking} =
            attrs
            |> Map.put("vendor_job_id", event.job_status_id)
            |> Map.put("vendor_id", event.id)
            |> Map.put("ttl", ttl)
            |> Bookings.create_booking()
    else {:error, _} ->
      {:error, %Ecto.Changeset{}}
    end
  end

  @doc """
  Updates a booking.

  ## Examples

      iex> update_booking(booking, %{field: new_value})
      {:ok, %Booking{}}

      iex> update_booking(booking, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_booking(%Booking{} = booking, attrs) do
    booking
    |> Booking.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a booking.

  ## Examples

      iex> delete_booking(booking)
      {:ok, %Booking{}}

      iex> delete_booking(booking)
      {:error, %Ecto.Changeset{}}

  """
  def delete_booking(%Booking{} = booking) do
    Repo.delete(booking)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking booking changes.

  ## Examples

      iex> change_booking(booking)
      %Ecto.Changeset{data: %Booking{}}

  """
  def change_booking(%Booking{} = booking, attrs \\ %{}) do
    Booking.changeset(booking, attrs)
  end
end
