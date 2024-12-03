defmodule LocalHospitalService.Repo.Migrations.CreateUsersTokensTables do
  use Ecto.Migration

  def change do
    create table(:users_tokens) do
      add :user_id, :integer, null: false
      add :token, :binary, null: false, size: 32
      add :context, :string, null: false
      add :sent_to, :string
      add :user, :map, null: false

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end
end
