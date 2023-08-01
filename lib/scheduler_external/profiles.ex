defmodule SchedulerExternal.Profiles do
  @moduledoc """
  The Profiles context.
  """

  import Ecto.Query, warn: false
  alias SchedulerExternal.Repo

  alias SchedulerExternal.Profiles.Profile

  @doc """
  Returns the list of profiles.

  ## Examples

      iex> list_profiles()
      [%Profile{}, ...]

  """
  def list_profiles do
    Repo.all(Profile)
  end

  @doc """
  Returns the list of profiles for a given user.

  ## Examples

      iex> list_profiles_by_user("123")
      [%Profile{}, ...]

  """
  def list_profiles_by_user(id) do
    Repo.all(from p in Profile, where: p.user_id == ^id)
  end

  @doc """
  Returns the list all public profiles.

  ## Examples

      iex> list_public_profiles()
      [%Profile{}, ...]

  """
  def list_public_profiles do
    Repo.all(from p in Profile, where: p.public? == true)
  end

  @doc """
  Gets a single profile.

  Raises `Ecto.NoResultsError` if the Profile does not exist.

  ## Examples

      iex> get_profile!(123)
      %Profile{}

      iex> get_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_profile!(id) do
    Repo.get!(Profile, id)
    |> Repo.preload(:pages)
  end

  @doc """
  Gets a single profile by slug.

  Raises `Ecto.NoResultsError` if the Profile does not exist.

  ## Examples

      iex> get_profile_by_slug!("slug")
      %Profile{}

      iex> get_profile_by_slug!("missing-slug")
      ** (Ecto.NoResultsError)

  """
  def get_profile_by_slug!(slug) do
    Repo.get_by!(Profile, slug: slug, public?: true)
    |> Repo.preload(:pages)
  end

  @doc """
  Creates a profile.

  ## Examples

      iex> create_profile(%{field: value})
      {:ok, %Profile{}}

      iex> create_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_profile(attrs \\ %{}) do
    %Profile{}
    |> Profile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a profile.

  ## Examples

      iex> update_profile(profile, %{field: new_value})
      {:ok, %Profile{}}

      iex> update_profile(profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profile(%Profile{} = profile, attrs) do
    profile
    |> Profile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a profile.

  ## Examples

      iex> delete_profile(profile)
      {:ok, %Profile{}}

      iex> delete_profile(profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_profile(%Profile{} = profile) do
    Repo.delete(profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking profile changes.

  ## Examples

      iex> change_profile(profile)
      %Ecto.Changeset{data: %Profile{}}

  """
  def change_profile(%Profile{} = profile, attrs \\ %{}) do
    Profile.changeset(profile, attrs)
  end
end
