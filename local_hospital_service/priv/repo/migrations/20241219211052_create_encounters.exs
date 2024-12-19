defmodule LocalHospitalService.Repo.Migrations.CreateEncounters do
  use Ecto.Migration

  def change do
    create table(:encounters) do
      add :priority, :integer
      add :reason, :string
      add :date_time, :naive_datetime
      add :patient, :string
      add :ward_id, references(:wards, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:encounters, [:ward_id])
  end
end
