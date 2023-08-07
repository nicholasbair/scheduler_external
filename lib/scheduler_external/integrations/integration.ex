defmodule SchedulerExternal.Integrations.Integration do
  @moduledoc """
  The Integration schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "integrations" do
    field :email_address, :string
    field :invalid_since, :utc_datetime
    field :token, SchedulerExternal.Encrypted.Binary
    field :valid?, :boolean, default: false
    field :vendor_id, :string

    belongs_to :user, SchedulerExternal.Accounts.User
    has_many :pages, SchedulerExternal.Pages.Page

    timestamps()
  end

  @doc false
  def changeset(integration, attrs) do
    integration
    |> cast(attrs, [:valid?, :token, :vendor_id, :email_address, :invalid_since, :user_id])
    |> validate_required([:valid?, :token, :vendor_id, :email_address])
  end
end
