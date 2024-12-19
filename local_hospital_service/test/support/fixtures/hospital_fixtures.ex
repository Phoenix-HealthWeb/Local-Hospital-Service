defmodule LocalHospitalService.HospitalFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LocalHospitalService.Hospital` context.
  """

  @doc """
  Generate an encounter.
  """
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
end
