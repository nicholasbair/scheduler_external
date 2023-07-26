defmodule SchedulerExternal.Integrations.Integration do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "integrations" do
    field :email_address, :string
    field :invalid_since, :utc_datetime
    field :token, :string
    field :valid, :boolean, default: false
    field :vendor_id, :string
    field :user_id, :binary_id

    timestamps()
  end

  @doc false
  def changeset(integration, attrs) do
    integration
    |> cast(attrs, [:valid, :token, :vendor_id, :email_address, :invalid_since])
    |> validate_required([:valid, :token, :vendor_id, :email_address, :invalid_since])
  end
end
