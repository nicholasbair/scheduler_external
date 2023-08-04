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
  # TODO: need to get integration status
  def list_pages(user_id) do
    query = from p in Page,
      where: p.user_id == ^user_id,
      order_by: [asc: p.title]
    Repo.all(query)
  end

  @doc """
  Returns the list of pages for a given integration.

  ## Examples

      iex> get_pages_by_integration_id(1234)
      [%Page{}, ...]

  """
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
  Gets a single page.

  ## Examples

      iex> get_page(123)
      {:ok, %Page{}}

      iex> get_page(456)
      {:error, :not_found}

  """
  def get_page(id) do
    Repo.get(Page, id)
    |> Repo.normalize_one()
  end

  @doc """
  Gets a single page by slug.

  Raises `Ecto.NoResultsError` if the Page does not exist.

  ## Examples

      iex> get_page_by_slug!(123)
      %Page{}

      iex> get_page_by_slug!(456)
      ** (Ecto.NoResultsError)

  """
  def get_page_by_slug!(slug) do
    Repo.get_by!(Page, [slug: slug, public?: true])
    # |> preload(:integration)
  end

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
        calendar_id = scheduler_page.config.calendar_ids[integration.vendor_id]["booking"]
        attrs = Map.merge(attrs, %{"vendor_id" => scheduler_page.id, "slug" => scheduler_page.slug, "calendar_id" => calendar_id})

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
    # TODO: if something like cost is changed but nothing else, no need to actually call the API
    with {:ok, integration} <- Integrations.get_integration_for_user(page.user_id, page.integration_id),
      {:ok, _scheduler_page} <- Provider.update_page(integration, attrs) do
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
    with {:ok, integration} <- SchedulerExternal.Integrations.get_integration(page.integration_id),
      {:ok, _} <- Provider.delete_page(integration, page) do
        Repo.delete(page)
    else _ ->
      {:error, %Ecto.Changeset{}}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking page changes.

  ## Examples

      iex> change_page(page)
      %Ecto.Changeset{data: %Page{}}

  """
  def change_page(%Page{} = page, attrs \\ %{}) do
    Page.changeset(page, attrs)
  end

  @doc """
  Returns the public URL for a page.

  ## Examples

      iex> slug_to_url(page)
      "https://example.com/services/1234"
  """
  def slug_to_url(%Page{} = page) do
    SchedulerExternalWeb.Endpoint.url() <> "/services/" <> page.slug
  end
end
