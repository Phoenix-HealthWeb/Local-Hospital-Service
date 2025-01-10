defmodule LocalHospitalService.MedicationRequests.MedicationRequest do
  use Ecto.Schema
  import Ecto.Query, warn: false
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
    |> cast_assoc(:patient, with: &LocalHospitalService.Hospital.Patient.changeset_relaxed/2)
    |> cast_assoc(:practitioner, with: &LocalHospitalService.Accounts.User.changeset_relaxed/2)
    |> validate_required([:date_time, :expiration_date, :medication, :posology])
  end

  @doc """
  Used to create a MedicationRequest struct from a map.
  """
  def struct!(_request, struct) do
    ch = changeset(%LocalHospitalService.MedicationRequests.MedicationRequest{}, struct)

    if(!ch.valid?) do
      raise "Invalid struct: #{inspect(ch.errors)}"
    else
      Ecto.Changeset.apply_changes(ch)
    end
  end

  @doc """
  Used to create a map from a MedicationRequest struct.
  """
  def data(%LocalHospitalService.MedicationRequests.MedicationRequest{} = request) do
    %{
      id: request.id,
      date_time: request.date_time,
      expiration_date: request.expiration_date,
      medication: request.medication,
      posology: request.posology,
      patient: %{
        id: request.patient.id
      },
      practitioner: %{
        id: request.practitioner.id
      }
    }
  end

  def syncronize_to_ndb(
        %LocalHospitalService.MedicationRequests.MedicationRequest{} = medication_request
      ) do
    LocalHospitalService.NdbSyncronization.Producer.produce(
      Jason.encode!(%{
        type: "medication_request",
        data: data(medication_request)
      })
    )
  end



end
