defmodule LocalHospitalService.Hospital.Ward do
  use Ecto.Schema
  import Ecto.Changeset

  schema "wards" do
    field :name, :string
    field :description, :string
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(ward, attrs) do
    ward
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
