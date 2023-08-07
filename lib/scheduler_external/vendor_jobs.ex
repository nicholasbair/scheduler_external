defmodule SchedulerExternal.Integrations.VendorJobs do

  import Ecto.Query, warn: false
  alias SchedulerExternal.Repo

  alias SchedulerExternal.Integrations.VendorJob

  @doc """
  Creates a vendor job.

  ## Examples

      iex> create_vendor_job(%{field: value})
      {:ok, %VendorJob{}}

      iex> create_vendor_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vendor_job(attrs \\ %{}) do
    %VendorJob{}
    |> VendorJob.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a job by vendor ID.

  ## Examples

      iex> get_job_by_vendor_id("123")
      {:ok, %VendorJob{}}

      iex> get_job_by_vendor_id("456")
      {:error, :not_found}
  """
  def get_job_by_vendor_id(id) do
    Repo.get_by(VendorJob, vendor_id: id)
    |> Repo.normalize_one()
  end

  @doc """
  Updates a vendor job.

  ## Examples

      iex> update_vendor_job(job, %{field: new_value})
      {:ok, %VendorJob{}}

      iex> update_vendor_job(job, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vendor_job(%VendorJob{} = job, attrs) do
    job
    |> VendorJob.changeset(attrs)
    |> Repo.update()
  end

end
