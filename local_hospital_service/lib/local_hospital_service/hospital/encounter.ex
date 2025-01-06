defmodule LocalHospitalService.Hospital.Encounter do
  use Ecto.Schema
  import Ecto.Changeset

  schema "encounters" do
    field :priority, :integer
    field :reason, :string
    field :date_time, :naive_datetime
    field :patient, :string
    field :status, :string #, default: "queue"  # Added patient status: queue or visit
    belongs_to :ward, LocalHospitalService.Hospital.Ward, foreign_key: :ward_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(encounter, attrs) do
    encounter
    |> cast(attrs, [:priority, :reason, :date_time, :patient, :status, :ward_id])
    |> validate_required([:priority, :reason, :date_time, :patient, :status, :ward_id])
    |> assoc_constraint(:ward)
    |> validate_inclusion(:status, ["queue", "in_visit"])
  end
end
