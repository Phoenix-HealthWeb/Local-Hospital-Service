defmodule LocalHospitalService.HospitalFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LocalHospitalService.Hospital` context.
  """

  @doc """
  Generate a ward.
  """
  def ward_fixture(attrs \\ %{}) do
    # Attributes
    {:ok, ward} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> LocalHospitalService.Hospital.create_ward()

    ward
  end
  def encounter_fixture(attrs \\ %{}) do
    # Create encounter with right attributes
    {:ok, encounter} =
      attrs
      |> Enum.into(%{
        priority: 1,  # Defines green priority color
        ward_id: 1,   # Defines ward 1
        reason: "some reason",
        date_time: ~N[2024-12-18 21:10:00],
        patient: "some patient"
      })
      |> LocalHospitalService.Hospital.create_encounter()

    encounter
  end

  @doc """
  Generate a patient.
  """
  def patient_fixture(attrs \\ %{}) do
    {:ok, patient} =
      attrs
      |> Enum.into(%{
        cf: "some cf",
        date_of_birth: ~D[2025-01-05],
        firstname: "some firstname",
        gender: "some gender",
        lastname: "some lastname"
      })
      |> LocalHospitalService.Hospital.create_patient()

    patient
  end
end
