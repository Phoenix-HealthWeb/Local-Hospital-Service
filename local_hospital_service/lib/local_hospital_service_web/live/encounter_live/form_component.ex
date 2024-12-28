defmodule LocalHospitalService.Hospital do
  @moduledoc """
  The Hospital context.
  """

  import Ecto.Query, warn: false
  alias LocalHospitalService.Repo

  alias LocalHospitalService.Hospital.Ward
  alias LocalHospitalService.Hospital.Encounter

  # Wards
  def list_wards do
    Repo.all(Ward)
  end

  def get_ward!(id), do: Repo.get!(Ward, id)

  def create_ward(attrs \\ %{}) do
    %Ward{}
    |> Ward.changeset(attrs)
    |> Repo.insert()
  end

  def update_ward(%Ward{} = ward, attrs) do
    ward
    |> Ward.changeset(attrs)
    |> Repo.update()
  end

  def delete_ward(%Ward{} = ward) do
    Repo.delete(ward)
  end

  def change_ward(%Ward{} = ward, attrs \\ %{}) do
    Ward.changeset(ward, attrs)
  end

  # Encounters
  def list_encounters do
    Repo.all(Encounter)
    |> Repo.preload(:ward)
    |> tap(&IO.inspect(&1, label: "Encounters with Preloaded Ward"))
  end

  def get_encounter!(id) do
    Repo.get!(Encounter, id)
    |> Repo.preload(:ward)
    |> tap(&IO.inspect(&1, label: "Encounter with Preloaded Ward"))
  end

  def create_encounter(attrs \\ %{}) do
    %Encounter{}
    |> Encounter.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:ward, with: &Ward.changeset/2)
    |> Repo.insert()
    |> case do
      {:ok, encounter} -> {:ok, Repo.preload(encounter, :ward)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_encounter(%Encounter{} = encounter, attrs) do
    encounter
    |> Encounter.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, encounter} -> {:ok, Repo.preload(encounter, :ward)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def delete_encounter(%Encounter{} = encounter) do
    Repo.delete(encounter)
  end

  def change_encounter(%Encounter{} = encounter, attrs \\ %{}) do
    Encounter.changeset(encounter, attrs)
  end
end
