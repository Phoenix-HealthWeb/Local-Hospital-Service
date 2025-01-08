defmodule LocalHospitalService.Api.Condition do
  @doc """
  Creates a Condition.
  """
  def create(%LocalHospitalService.Conditions.Condition{} = condition) do
    LocalHospitalService.Api.post("conditions", %{
      condition: LocalHospitalService.Conditions.Condition.data(condition)
    })
    |> case do
      {:ok, data} -> {:ok, LocalHospitalService.Conditions.Condition.struct!(nil, data)}
      {:error, reason} -> {:error, reason}
    end
  end
end
