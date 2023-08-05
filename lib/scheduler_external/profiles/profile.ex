defmodule SchedulerExternal.Profiles.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "profiles" do
    field :description, :string
    field :name, :string
    field :public?, :boolean, default: false
    field :slug, :string

    has_many :pages, SchedulerExternal.Pages.Page
    belongs_to :user, SchedulerExternal.Users.User

    timestamps()
  end

  @doc false
  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:public?, :name, :description, :slug, :user_id])
    |> validate_required([:public?, :name, :description, :slug, :user_id])
  end
end
