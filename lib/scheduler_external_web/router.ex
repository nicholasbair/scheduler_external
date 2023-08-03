defmodule SchedulerExternalWeb.Router do
  use SchedulerExternalWeb, :router

  import SchedulerExternalWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SchedulerExternalWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SchedulerExternalWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", SchedulerExternalWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:scheduler_external, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SchedulerExternalWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", SchedulerExternalWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{SchedulerExternalWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", SchedulerExternalWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/integrations/callback", IntegrationController, :callback

    live_session :require_authenticated_user,
      on_mount: [{SchedulerExternalWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      live "/integrations", IntegrationLive.Index, :index
      live "/integrations/new", IntegrationLive.Index, :new
      live "/integrations/:id", IntegrationLive.Show, :show

      live "/pages", PageLive.Index, :index
      live "/pages/new", PageLive.Index, :new
      live "/pages/:id", PageLive.Show, :show
      live "/pages/:id/edit", PageLive.Show, :edit

      live "/profiles", ProfileLive.Index, :index
      live "/profiles/new", ProfileLive.Index, :new
      live "/profiles/:id", ProfileLive.Show, :show
      live "/profiles/:id/edit", ProfileLive.Show, :edit
    end
  end

  scope "/", SchedulerExternalWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{SchedulerExternalWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end

    live "/service-profiles", ServiceProfileLive.Index, :index
    live "/service-profiles/:slug", ServiceProfileLive.Show, :show

    live "/services/:slug", ServiceLive.Parent, :show
    live "/bookings/callback", ServiceLive.Callback, :callback

    live "/bookings/new", BookingLive.Index, :new
  end
end
