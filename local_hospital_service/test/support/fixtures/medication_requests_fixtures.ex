defmodule LocalHospitalService.MedicationRequestsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LocalHospitalService.MedicationRequests` context.
  """

  @doc """
  Generate a medication_request.
  """
  def medication_request_fixture(attrs \\ %{}) do
    {:ok, medication_request} =
      attrs
      |> Enum.into(%{
        date_time: ~U[2025-01-07 15:19:00Z],
        expiration_date: ~D[2025-01-07],
        medication: "some medication",
        posology: "some posology"
      })
      |> LocalHospitalService.MedicationRequests.create_medication_request()

    medication_request
  end
end
