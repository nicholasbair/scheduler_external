defmodule SchedulerExternal.Repo do
  use Ecto.Repo,
    otp_app: :scheduler_external,
    adapter: Ecto.Adapters.Postgres

  def normalize_one(result) do
    case result do
      nil -> {:error, :not_found}
      record -> {:ok, record}
    end
  end
end
