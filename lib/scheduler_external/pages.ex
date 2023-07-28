defmodule SchedulerExternal.Pages do
  @moduledoc """
  The Pages context.
  """

  import Ecto.Query, warn: false
  require Logger
  alias SchedulerExternal.Repo

  alias SchedulerExternal.Pages.Page
  alias SchedulerExternal.Integrations
  alias SchedulerExternal.Integrations.Provider

  @doc """
  Returns the list of pages.

  ## Examples

      iex> list_pages()
      [%Page{}, ...]

  """
  def list_pages(user_id) do
    query = from p in Page,
      where: p.user_id == ^user_id,
      order_by: [asc: p.title]
    Repo.all(query)
  end

  def get_pages_by_integration_id(id) do
    query = from p in Page,
      where: p.integration_id == ^id,
      order_by: [asc: p.title]
    Repo.all(query)
  end

  @doc """
  Gets a single page.

  Raises `Ecto.NoResultsError` if the Page does not exist.

  ## Examples

      iex> get_page!(123)
      %Page{}

      iex> get_page!(456)
      ** (Ecto.NoResultsError)

  """
  def get_page!(id), do: Repo.get!(Page, id)

  @doc """
  Creates a page.

  ## Examples

      iex> create_page(%{field: value})
      {:ok, %Page{}}

      iex> create_page(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_page(%{"user_id" => user_id, "integration_id" => integration_id} = attrs \\ %{}) do
    with {:ok, integration} <- Integrations.get_integration_for_user(user_id, integration_id),
      {:ok, scheduler_page} <- Provider.create_page(integration, attrs) do
        attrs = Map.merge(attrs, %{"vendor_id" => scheduler_page.id, "slug" => scheduler_page.slug})

        %Page{}
        |> Page.changeset(attrs)
        |> Repo.insert()
    else _ ->
      {:error, %Ecto.Changeset{}}
    end
  end

  @doc """
  Updates a page.

  ## Examples

      iex> update_page(page, %{field: new_value})
      {:ok, %Page{}}

      iex> update_page(page, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_page(%Page{} = page, attrs) do
    # Scheduler API is a PUT, so need to fetch the page first?
    # TODO: if something like cost is changed but nothing else, no need to actually call the API
    with {:ok, integration} <- Integrations.get_integration_for_user(page.user_id, page.integration_id),
      {:ok, _scheduler_page} <- Provider.update_page(integration, attrs) do
        # attrs = Map.merge(attrs, %{"vendor_id" => scheduler_page.id, "slug" => scheduler_page.slug})

        page
        |> Page.changeset(attrs)
        |> Repo.update()
    else _ ->
      {:error, %Ecto.Changeset{}}
    end
  end

  @doc """
  Deletes a page.

  ## Examples

      iex> delete_page(page)
      {:ok, %Page{}}

      iex> delete_page(page)
      {:error, %Ecto.Changeset{}}

  """
  def delete_page(%Page{} = page) do
    Repo.delete(page)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking page changes.

  ## Examples

      iex> change_page(page)
      %Ecto.Changeset{data: %Page{}}

  """
  def change_page(%Page{} = page, attrs \\ %{}) do
    # raise "hello from change_page"

    # This gets called with every change to the form which runs the validations at the model level

    Page.changeset(page, attrs)
  end
end
