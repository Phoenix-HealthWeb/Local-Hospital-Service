defmodule LocalHospitalService.Conditions.Condition do
  use Ecto.Schema
  import Ecto.Changeset

  schema "conditions" do
    field :comment, :string
    field :date_time, :utc_datetime
    belongs_to :patient, LocalHospitalService.Hospital.Patient
    belongs_to :practitioner, LocalHospitalService.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(condition, attrs) do
    condition
    |> cast(attrs, [:id, :comment, :date_time])
    |> cast_assoc(:patient, with: &LocalHospitalService.Hospital.Patient.changeset_relaxed/2)
    |> cast_assoc(:practitioner, with: &LocalHospitalService.Accounts.User.changeset_relaxed/2)
    |> validate_required([:comment, :date_time])
  end

  @doc """
  Used to create a Condition struct from a map.
  """
  def struct!(_condition, struct) do
    ch = changeset(%LocalHospitalService.Conditions.Condition{}, struct)

    if(!ch.valid?) do
      raise "Invalid struct: #{inspect(ch.errors)}"
    else
      Ecto.Changeset.apply_changes(ch)
    end
  end

  @doc """
  Used to create a map from a Condition struct.
  """
  def data(%LocalHospitalService.Conditions.Condition{} = condition) do
    %{
      id: condition.id,
      comment: condition.comment,
      date_time: condition.date_time,
      patient_id: condition.patient.id,
      practitioner_id: condition.practitioner.id
    }
  end

  def syncronize_to_ndb(%LocalHospitalService.Conditions.Condition{} = condition) do
    LocalHospitalService.NdbSyncronization.Producer.produce(
      Jason.encode!(%{
        type: "condition",
        data: data(condition)
      })
    )
  end
end
