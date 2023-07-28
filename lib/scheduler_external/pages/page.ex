defmodule SchedulerExternal.Pages.Page do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pages" do
    field :valid?, :boolean, default: true
    field :vendor_id, :integer
    field :user_id, :binary_id
    field :integration_id, :binary_id
    field :title, :string
    field :cost, :integer
    field :slug, :string
    field :duration, :integer
    field :location, :string

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:valid?, :vendor_id, :user_id, :integration_id, :title, :cost, :slug, :duration, :location])
    |> validate_required([:integration_id, :title, :cost, :duration, :location])
  end
end
