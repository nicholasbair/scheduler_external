defmodule SchedulerExternal.ProfilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SchedulerExternal.Profiles` context.
  """

  @doc """
  Generate a profile.
  """
  def profile_fixture(attrs \\ %{}) do
    {:ok, profile} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        public: true
      })
      |> SchedulerExternal.Profiles.create_profile()

    profile
  end
end
