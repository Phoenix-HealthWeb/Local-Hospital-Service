defmodule LocalHospitalService.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LocalHospitalServiceWeb.Telemetry,
      LocalHospitalService.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:local_hospital_service, :ecto_repos),
       skip: skip_migrations?()},
      {DNSCluster,
       query: Application.get_env(:local_hospital_service, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LocalHospitalService.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: LocalHospitalService.Finch},
      # Start a worker by calling: LocalHospitalService.Worker.start_link(arg)
      # {LocalHospitalService.Worker, arg},
      # Start to serve requests, typically the last entry
      LocalHospitalServiceWeb.Endpoint,
      # Start the NDB Syncronization supervisor
      LocalHospitalService.NdbSyncronization.Supervisor,
      # Populate the wards table with initial data
      {Task,
       fn ->
         Mix.Tasks.Populate.Wards.run([Path.expand("../../priv/data/initial_wards.csv", __DIR__)])
       end}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LocalHospitalService.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LocalHospitalServiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    # Additionally, migrations are made if we set the FORCE_MIGRATIONS
    System.get_env("RELEASE_NAME") != nil &&
      System.get_env("FORCE_MIGRATIONS") != "true"
  end
end
