defmodule LocalHospitalService.Repo.Migrations.CreateEncounters do
  use Ecto.Migration

  def change do
    create table(:encounters) do
      add :"\\", :string
      add :priority, :integer
      add :"\\", :string
      add :"\\", :string
      add :reason, :string
      add :"\\", :string
      add :date_time, :naive_datetime
      add :"\\", :string
      add :patient, :string
      add :ward_id, references(:wards, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:encounters, [:ward_id])
  end
end
