defmodule LocalHospitalService.Hospital.Patient do
  use Ecto.Schema
  import Ecto.Changeset

  schema "patients" do
    field :cf, :string
    field :firstname, :string
    field :lastname, :string
    field :date_of_birth, :date
    field :gender, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(patient, attrs) do
    patient
    |> cast(attrs, [:cf, :firstname, :lastname, :date_of_birth, :gender])
    |> validate_required([:cf, :firstname, :lastname, :date_of_birth, :gender])
  end
end
