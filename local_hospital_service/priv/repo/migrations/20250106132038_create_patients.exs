defmodule LocalHospitalService.Repo.Migrations.CreatePatients do
  use Ecto.Migration

  def change do
    create table(:patients) do
      add :cf, :string
      add :firstname, :string
      add :lastname, :string
      add :date_of_birth, :date
      add :gender, :string

      timestamps(type: :utc_datetime)
    end
  end
end
