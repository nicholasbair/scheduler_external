defmodule SchedulerExternal.PagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SchedulerExternal.Pages` context.
  """

  @doc """
  Generate a page.
  """
  def page_fixture(attrs \\ %{}) do
    {:ok, page} =
      attrs
      |> Enum.into(%{
        valid: true,
        vendor_id: "some vendor_id"
      })
      |> SchedulerExternal.Pages.create_page()

    page
  end
end
