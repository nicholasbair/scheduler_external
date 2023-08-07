defmodule SchedulerExternal.Pages.Page do
  @moduledoc """
  The Page schema.

  The page represents the scheduler page that is created on Nylas with the addition of having a cost and the ability to be marked as public or hidden.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pages" do
    field :vendor_id, :integer
    field :title, :string
    field :cost, :integer
    field :slug, :string
    field :duration, :integer
    field :location, :string
    field :public?, :boolean, default: false
    field :calendar_id, :string

    belongs_to :user, SchedulerExternal.Accounts.User
    belongs_to :profile, SchedulerExternal.Profiles.Profile
    belongs_to :integration, SchedulerExternal.Integrations.Integration
    has_many :bookings, SchedulerExternal.Bookings.Booking

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:vendor_id, :user_id, :integration_id, :title, :cost, :slug, :duration, :location, :public?, :profile_id, :calendar_id])
    |> validate_required([:integration_id, :title, :cost, :duration, :location])
  end
end
