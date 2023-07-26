defmodule SchedulerExternal.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SchedulerExternalWeb.Telemetry,
      # Start the Ecto repository
      SchedulerExternal.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: SchedulerExternal.PubSub},
      # Start Finch
      {Finch, name: SchedulerExternal.Finch},
      # Start the Endpoint (http/https)
      SchedulerExternalWeb.Endpoint,
      SchedulerExternal.Vault,
      {Oban, Application.fetch_env!(:scheduler_external, Oban)}
      # Start a worker by calling: SchedulerExternal.Worker.start_link(arg)
      # {SchedulerExternal.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SchedulerExternal.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SchedulerExternalWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
