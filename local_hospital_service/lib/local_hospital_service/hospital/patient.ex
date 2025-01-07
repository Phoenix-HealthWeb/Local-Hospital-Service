defmodule LocalHospitalService.Hospital.Patient do
  use Ecto.Schema
  import Ecto.Changeset

  schema "patients" do
    field :cf, :string
    field :firstname, :string
    field :lastname, :string
    field :date_of_birth, :date
    field :gender, :string
    has_many :conditions, LocalHospitalService.Conditions.Condition

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(patient, attrs) do
    patient
    |> cast(attrs, [:cf, :firstname, :lastname, :date_of_birth, :gender])
    |> cast_assoc(:conditions, with: &LocalHospitalService.Conditions.Condition.changeset/2)
    |> validate_required([:cf, :firstname, :lastname, :date_of_birth, :gender])
  end

  @doc """
  Used to create a Patient struct from a map.
  """
  def struct!(_patient, struct) do
    ch = changeset(%LocalHospitalService.Hospital.Patient{}, struct)

    if(!ch.valid?) do
      raise "Invalid struct: #{inspect(ch.errors)}"
    else
      Ecto.Changeset.apply_changes(ch)
    end
  end

  @doc """
  Used to create a map from a Patient struct.
  """
  def data(%LocalHospitalService.Hospital.Patient{} = patient) do
    %{
      id: patient.id,
      cf: patient.cf,
      firstname: patient.firstname,
      lastname: patient.lastname,
      date_of_birth: patient.date_of_birth,
      gender: patient.gender
    }
  end

  def syncronize_to_ndb(%LocalHospitalService.Hospital.Patient{} = patient) do
    LocalHospitalService.NdbSyncronization.Producer.produce(
      Jason.encode!(%{
        type: "patient",
        data: data(patient)
      })
    )
  end
end
