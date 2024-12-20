defmodule LocalHospitalService.Hospital.Encounter do
  use Ecto.Schema
  import Ecto.Changeset
# Fixed wrong field "\\"
  schema "encounters" do
    field :priority, :integer
    field :reason, :string
    field :date_time, :naive_datetime
    field :patient, :string
    belongs_to :ward, LocalHospitalService.Hospital.Ward

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(encounter, attrs) do
    encounter
    |> cast(attrs, [:priority, :reason, :date_time, :patient])
    |> validate_required([:priority, :reason, :date_time, :patient])
  end
end
