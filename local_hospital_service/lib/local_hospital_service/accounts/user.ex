defmodule LocalHospitalService.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  # The primary key is an integer without auto-generation
  @primary_key {:id, :id, autogenerate: false}

  embedded_schema do
    field :email, :string
    field :forename, :string
    field :surname, :string
    field :date_of_birth, :date
    field :qualification, :string
    field :gender_id, :id
    field :role_id, :id
    # has_many :medication_requests, NdbRestApi.MedicationRequests.MedicationRequest
    # timestamps(type: :utc_datetime)
  end

  def struct!(struct) do
    ch = changeset(%LocalHospitalService.Accounts.User{}, struct)

    if(!ch.valid?) do
      raise "Invalid struct: #{inspect(ch.errors)}"
    else
      Ecto.Changeset.apply_changes(ch)
    end
  end

  defp changeset(practitioner, attrs) do
    practitioner
    |> cast(attrs, [:id, :email, :forename, :surname, :date_of_birth, :qualification])
    |> validate_required([:id, :email, :forename, :surname, :date_of_birth, :qualification])
  end
end
