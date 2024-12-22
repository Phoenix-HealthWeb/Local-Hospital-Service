defmodule LocalHospitalService.Hospital.Encounter do
  use Ecto.Schema
  import Ecto.Changeset

  # Fixed wrong field
  @statuses ~w(queue in_visit)a

  schema "encounters" do
    field :priority, :integer
    field :reason, :string
    field :date_time, :naive_datetime
    field :patient, :string
    field :status, :string, default: "queue"  # Added patient status: queue or visit
    belongs_to :ward, LocalHospitalService.Hospital.Ward

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(encounter, attrs) do
    encounter
    |> cast(attrs, [:priority, :reason, :date_time, :patient, :status])
    |> validate_required([:priority, :reason, :date_time, :patient])
    |> validate_inclusion(:status, @statuses)
  end
end
