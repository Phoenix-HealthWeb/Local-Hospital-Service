defmodule LocalHospitalService.Hospital do
  @moduledoc """
  The Hospital context.
  """

  import Ecto.Query, warn: false
  alias LocalHospitalService.Repo

  alias LocalHospitalService.Hospital.Ward

  @doc """
  Returns the list of wards.

  ## Examples

      iex> list_wards()
      [%Ward{}, ...]

  """
  def list_wards do
    Repo.all(Ward)
  end

  @doc """
  Gets a single ward.

  Raises `Ecto.NoResultsError` if the Ward does not exist.

  ## Examples

      iex> get_ward!(123)
      %Ward{}

      iex> get_ward!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ward!(id), do: Repo.get!(Ward, id)

  @doc """
  Creates a ward.

  ## Examples

      iex> create_ward(%{field: value})
      {:ok, %Ward{}}

      iex> create_ward(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ward(attrs \\ %{}) do
    %Ward{}
    |> Ward.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ward.

  ## Examples

      iex> update_ward(ward, %{field: new_value})
      {:ok, %Ward{}}

      iex> update_ward(ward, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ward(%Ward{} = ward, attrs) do
    ward
    |> Ward.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ward.

  ## Examples

      iex> delete_ward(ward)
      {:ok, %Ward{}}

      iex> delete_ward(ward)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ward(%Ward{} = ward) do
    Repo.delete(ward)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ward changes.

  ## Examples

      iex> change_ward(ward)
      %Ecto.Changeset{data: %Ward{}}

  """
  def change_ward(%Ward{} = ward, attrs \\ %{}) do
    Ward.changeset(ward, attrs)
  end

alias LocalHospitalService.Hospital.Encounter

  @doc """
  Returns the list of encounters.

  ## Examples

      iex> list_encounters()
      [%Encounter{}, ...]

  """
  def list_encounters do
    Repo.all(Encounter)
    |> Repo.preload(:ward)
  end

  @doc """
  Gets a single encounter.

  Raises `Ecto.NoResultsError` if the Encounter does not exist.

  ## Examples

      iex> get_encounter!(123)
      %Encounter{}

      iex> get_encounter!(456)
      ** (Ecto.NoResultsError)

  """
  def get_encounter!(id), do: Repo.get!(Encounter, id)

  @doc """
  Creates a encounter.

  ## Examples

      iex> create_encounter(%{field: value})
      {:ok, %Encounter{}}

      iex> create_encounter(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_encounter(attrs \\ %{}) do
    %Encounter{}
    |> Encounter.changeset(attrs)
    |> Repo.preload(:ward)
    |> Repo.insert()
  end

  @doc """
  Updates a encounter.

  ## Examples

      iex> update_encounter(encounter, %{field: new_value})
      {:ok, %Encounter{}}

      iex> update_encounter(encounter, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_encounter(%Encounter{} = encounter, attrs) do
    encounter
    |> Encounter.changeset(attrs)
    |> Repo.update()

  end

  @doc """
  Deletes a encounter.

  ## Examples

      iex> delete_encounter(encounter)
      {:ok, %Encounter{}}

      iex> delete_encounter(encounter)
      {:error, %Ecto.Changeset{}}

  """
  def delete_encounter(%Encounter{} = encounter) do
    Repo.delete(encounter)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking encounter changes.

  ## Examples

      iex> change_encounter(encounter)
      %Ecto.Changeset{data: %Encounter{}}

  """
  def change_encounter(%Encounter{} = encounter, attrs \\ %{}) do
    Encounter.changeset(encounter, attrs)
  end
end
