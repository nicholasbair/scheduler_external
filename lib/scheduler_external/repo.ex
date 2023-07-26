defmodule SchedulerExternal.Repo do
  use Ecto.Repo,
    otp_app: :scheduler_external,
    adapter: Ecto.Adapters.Postgres
end
