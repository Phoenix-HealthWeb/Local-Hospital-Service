defmodule LocalHospitalService.MedicationRequests.MedicationRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "medication_request" do
    field :date_time, :utc_datetime
    field :expiration_date, :date
    field :medication, :string
    field :posology, :string
    belongs_to :patient, LocalHospitalService.Hospital.Patient
    belongs_to :practitioner, LocalHospitalService.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(medication_request, attrs) do
    medication_request
    |> cast(attrs, [:date_time, :expiration_date, :medication, :posology])
    |> validate_required([:date_time, :expiration_date, :medication, :posology])
  end
end
