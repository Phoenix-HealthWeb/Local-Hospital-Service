defmodule LocalHospitalServiceWeb.Router do
  alias LocalHospitalServiceWeb.DoctorLive
  alias LocalHospitalService.Api.MedicationRequest
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
    pipe_through [:browser, :redirect_on_user_role]

    # This page is actually never used. We rely on redirect_on_user_role to redirect to the correct landing page
    get "/", PageController, :home
  end

  scope "/admin", LocalHospitalServiceWeb do
    pipe_through :browser
  end

  scope "/nurses", LocalHospitalServiceWeb do
  #  pipe_through [:browser, :require_authenticated_nurse]
    pipe_through [:browser]
    get "/", PageController, :nurses

    live_session :nurses,
      on_mount: [{LocalHospitalServiceWeb.UserAuth, :mount_current_user}] do
      live "/cf_verification", CfVerificationLive, :verify
      live "/encounters", EncounterLive.Index, :index
      live "/encounters/new", EncounterLive.Index, :new
      live "/encounters/:id/edit", EncounterLive.Index, :edit

      live "/encounters/:id", EncounterLive.Show, :show
      live "/encounters/:id/show/edit", EncounterLive.Show, :edit

      live "/patients", PatientLive.Index, :index
      live "/patients/new", PatientLive.Index, :new
      live "/patients/:id/edit", PatientLive.Index, :edit
      live "/patients/:id", PatientLive.Show, :show
      live "/patients/:id/show/edit", PatientLive.Show, :edit
    end
  end

  scope "/doctors", LocalHospitalServiceWeb do
    pipe_through [:browser, :require_authenticated_doctor]

    get "/", PageController, :doctors

    live_session :doctors,
      on_mount: [{LocalHospitalServiceWeb.UserAuth, :mount_current_user}] do

        live "/wards", DoctorLive.Index, :index
        live "/wards/:wardId", DoctorLive.Indexxx, :indexxx
        live "/wards/:wardId/visit", DoctorLive.Index2, :index2
        live "/wards/:wardId/visit/:cf", DoctorLive.Index3, :index3
        live "/wards/:wardId/visit/:cf/conditions", ConditionLive.Index, :index
        live "/wards/:wardId/visit/:cf/observations", ObservationLive.Index, :index
        live "/wards/:wardId/visit/:cf/medical_requests", MedicationRequestLive.Index, :index
    end
  end

  scope "/admin", LocalHospitalServiceWeb do
    pipe_through [:browser, :require_authenticated_admin]

    get "/", PageController, :admins

    live_session :admin,
      on_mount: [{LocalHospitalServiceWeb.UserAuth, :mount_current_user}] do
      live "/wards", WardLive.Index, :index
      live "/wards/new", WardLive.Index, :new
      live "/wards/:id/edit", WardLive.Index, :edit
      live "/wards/:id", WardLive.Show, :show
      live "/wards/:id/show/edit", WardLive.Show, :edit
    end
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
