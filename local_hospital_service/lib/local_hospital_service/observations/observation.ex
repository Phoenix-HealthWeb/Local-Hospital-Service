defmodule LocalHospitalService.Observations.Observation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "observation" do
    field :date_time, :utc_datetime
    field :result, :string
    field :ward, :string
    field :hospital_id, :string
    belongs_to :patient, LocalHospitalService.Hospital.Patient
    belongs_to :practitioner, LocalHospitalService.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(observation, attrs) do
    observation
    |> cast(attrs, [:date_time, :ward, :result, :hospital_id])
    |> cast_assoc(:patient, with: &LocalHospitalService.Hospital.Patient.changeset_relaxed/2)
    |> cast_assoc(:practitioner, with: &LocalHospitalService.Accounts.User.changeset_relaxed/2)
    |> validate_required([:date_time, :ward, :result])
  end

  @doc """
  Used to create a Observation struct from a map.
  """
  def struct!(_observation, struct) do
    ch = changeset(%LocalHospitalService.Observations.Observation{}, struct)

    if(!ch.valid?) do
      raise "Invalid struct: #{inspect(ch.errors)}"
    else
      Ecto.Changeset.apply_changes(ch)
    end
  end

  @doc """
  Used to create a map from a Observation struct.
  """
  def data(%LocalHospitalService.Observations.Observation{} = observation) do
    %{
      id: observation.id,
      date_time: observation.date_time,
      ward: observation.ward,
      hospital_id: observation.hospital_id,
      result: observation.result,
      patient: %{
        id: observation.patient.id
      },
      practitioner: %{
        id: observation.practitioner.id
      }
    }
  end

  def syncronize_to_ndb(
        %LocalHospitalService.Observations.Observation{} = observation
      ) do
    LocalHospitalService.NdbSyncronization.Producer.produce(
      Jason.encode!(%{
        type: "observation",
        data: data(observation)
      })
    )
  end
end
