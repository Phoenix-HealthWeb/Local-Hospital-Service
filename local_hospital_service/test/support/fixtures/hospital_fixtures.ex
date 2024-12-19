defmodule LocalHospitalService.HospitalFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LocalHospitalService.Hospital` context.
  """

  @doc """
  Generate a ward.
  """
  def ward_fixture(attrs \\ %{}) do
    {:ok, ward} =
      attrs
      |> Enum.into(%{
        \: "some \\",
        \description: "some \\description",
        name: "some name"
      })
      |> LocalHospitalService.Hospital.create_ward()

    ward
  end
end
