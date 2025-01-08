defmodule LocalHospitalService.ConditionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LocalHospitalService.Conditions` context.
  """

  @doc """
  Generate a condition.
  """
  def condition_fixture(attrs \\ %{}) do
    {:ok, condition} =
      attrs
      |> Enum.into(%{
        comment: "some comment",
        date_time: ~U[2025-01-06 18:16:00Z]
      })
      |> LocalHospitalService.Conditions.create_condition()

    condition
  end
end
