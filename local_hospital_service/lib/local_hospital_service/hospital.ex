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

  alias LocalHospitalService.Hospital.Patient

  @doc """
  Returns the list of patients.

  ## Examples

      iex> list_patients()
      [%Patient{}, ...]

  """
  def list_patients do
    Repo.all(Patient)
  end

  @doc """
  Gets a single patient.

  Raises `Ecto.NoResultsError` if the Patient does not exist.

  ## Examples

      iex> get_patient!(123)
      %Patient{}

      iex> get_patient!(456)
      ** (Ecto.NoResultsError)

  """
  def get_patient!(id), do: Repo.get!(Patient, id)

  @doc """
  Creates a patient.

  ## Examples

      iex> create_patient(%{field: value})
      {:ok, %Patient{}}

      iex> create_patient(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
def create_patient(attrs \\ %{}) do
  %Patient{}
  |> Patient.changeset(attrs)
  |> Repo.insert()
  |> case do
    {:ok, patient} ->
      # Syncronize with NDB
      LocalHospitalService.Hospital.Patient.syncronize_to_ndb(patient)
      {:ok, patient}

    {:error, changeset} ->
      {:error, changeset}
  end
end

  @doc """
  Updates a patient.

  ## Examples

      iex> update_patient(patient, %{field: new_value})
      {:ok, %Patient{}}

      iex> update_patient(patient, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_patient(%Patient{} = patient, attrs) do
    patient
    |> Patient.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a patient.

  ## Examples

      iex> delete_patient(patient)
      {:ok, %Patient{}}

      iex> delete_patient(patient)
      {:error, %Ecto.Changeset{}}

  """
  def delete_patient(%Patient{} = patient) do
    Repo.delete(patient)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking patient changes.

  ## Examples

      iex> change_patient(patient)
      %Ecto.Changeset{data: %Patient{}}

  """
  def change_patient(%Patient{} = patient, attrs \\ %{}) do
    Patient.changeset(patient, attrs)
  end
end
