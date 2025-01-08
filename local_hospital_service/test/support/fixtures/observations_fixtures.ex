defmodule LocalHospitalService.ObservationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LocalHospitalService.Observations` context.
  """

  @doc """
  Generate a observation.
  """
  def observation_fixture(attrs \\ %{}) do
    {:ok, observation} =
      attrs
      |> Enum.into(%{
        date_time: ~U[2025-01-07 17:05:00Z],
        hospital_id: "some hospital_id",
        ward: "some ward"
      })
      |> LocalHospitalService.Observations.create_observation()

    observation
  end
end
