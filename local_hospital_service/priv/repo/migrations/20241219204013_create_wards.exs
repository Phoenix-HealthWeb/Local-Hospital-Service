defmodule LocalHospitalService.Repo.Migrations.CreateWards do
  use Ecto.Migration

  def change do
    create table(:wards) do
      add :name, :string
      add :description, :string

      timestamps(type: :utc_datetime)
    end
  end
end
