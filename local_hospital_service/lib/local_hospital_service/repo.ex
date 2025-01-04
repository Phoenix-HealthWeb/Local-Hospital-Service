defmodule LocalHospitalService.Repo do
  use Ecto.Repo,
    otp_app: :local_hospital_service,
    #adapter: Ecto.Adapters.Postgres
    adapter: Ecto.Adapters.SQLite3
end
