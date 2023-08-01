defmodule SchedulerExternal.ProfilesTest do
  use SchedulerExternal.DataCase

  alias SchedulerExternal.Profiles

  describe "profiles" do
    alias SchedulerExternal.Profiles.Profile

    import SchedulerExternal.ProfilesFixtures

    @invalid_attrs %{description: nil, name: nil, public: nil}

    test "list_profiles/0 returns all profiles" do
      profile = profile_fixture()
      assert Profiles.list_profiles() == [profile]
    end

    test "get_profile!/1 returns the profile with given id" do
      profile = profile_fixture()
      assert Profiles.get_profile!(profile.id) == profile
    end

    test "create_profile/1 with valid data creates a profile" do
      valid_attrs = %{description: "some description", name: "some name", public: true}

      assert {:ok, %Profile{} = profile} = Profiles.create_profile(valid_attrs)
      assert profile.description == "some description"
      assert profile.name == "some name"
      assert profile.public == true
    end

    test "create_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Profiles.create_profile(@invalid_attrs)
    end

    test "update_profile/2 with valid data updates the profile" do
      profile = profile_fixture()
      update_attrs = %{description: "some updated description", name: "some updated name", public: false}

      assert {:ok, %Profile{} = profile} = Profiles.update_profile(profile, update_attrs)
      assert profile.description == "some updated description"
      assert profile.name == "some updated name"
      assert profile.public == false
    end

    test "update_profile/2 with invalid data returns error changeset" do
      profile = profile_fixture()
      assert {:error, %Ecto.Changeset{}} = Profiles.update_profile(profile, @invalid_attrs)
      assert profile == Profiles.get_profile!(profile.id)
    end

    test "delete_profile/1 deletes the profile" do
      profile = profile_fixture()
      assert {:ok, %Profile{}} = Profiles.delete_profile(profile)
      assert_raise Ecto.NoResultsError, fn -> Profiles.get_profile!(profile.id) end
    end

    test "change_profile/1 returns a profile changeset" do
      profile = profile_fixture()
      assert %Ecto.Changeset{} = Profiles.change_profile(profile)
    end
  end
end
