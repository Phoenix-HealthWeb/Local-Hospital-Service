defmodule LocalHospitalService.Api.Condition do
  @doc """
  Creates a Condition.
  """
  def create(%LocalHospitalService.Conditions.Condition{} = condition) do
    LocalHospitalService.Api.post("conditions", %{
      condition: LocalHospitalService.Conditions.Condition.data(condition)
    })
    |> case do
      {:ok, data} -> LocalHospitalService.Conditions.Condition.struct!(nil, data)
      {:error, _} -> nil
    end
  end
end
