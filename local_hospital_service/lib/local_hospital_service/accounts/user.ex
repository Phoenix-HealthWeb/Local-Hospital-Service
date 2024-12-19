defmodule LocalHospitalService.Accounts.User do
  use Ecto.Schema

  # # TODO: Should be :id maybe just for mock. Then, delete this row
  @primary_key {:id, :id, autogenerate: false}

  embedded_schema do
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :current_password, :string, virtual: true, redact: true
    field :confirmed_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end
end
