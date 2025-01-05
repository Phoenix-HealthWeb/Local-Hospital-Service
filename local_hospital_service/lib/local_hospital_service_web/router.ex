defmodule LocalHospitalServiceWeb.Router do
  use LocalHospitalServiceWeb, :router

  import LocalHospitalServiceWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LocalHospitalServiceWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LocalHospitalServiceWeb do
    pipe_through :browser
    live "nurses/encounters", EncounterLive.Index, :index
    live "nurses/encounters/new", EncounterLive.Index, :new
    live "nurses/encounters/:id/edit", EncounterLive.Index, :edit

    live "nurses/encounters/:id", EncounterLive.Show, :show
    live "nurses/encounters/:id/show/edit", EncounterLive.Show, :edit

    get "/", PageController, :home
  end

  scope "/admin", LocalHospitalServiceWeb do
    pipe_through :browser

    live "/wards", WardLive.Index, :index
    live "/wards/new", WardLive.Index, :new
    live "/wards/:id/edit", WardLive.Index, :edit
    live "/wards/:id", WardLive.Show, :show
    live "/wards/:id/show/edit", WardLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", LocalHospitalServiceWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:local_hospital_service, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LocalHospitalServiceWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", LocalHospitalServiceWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{LocalHospitalServiceWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/log_in", UserLoginLive, :new
      live "/users/log_in/:token", UserLoginMagicLinkLive, :new
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", LocalHospitalServiceWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
  end
end
