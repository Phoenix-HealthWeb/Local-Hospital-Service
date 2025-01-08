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
    |> validate_required([:comment, :date_time])
  end
end
