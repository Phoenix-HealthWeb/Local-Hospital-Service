defmodule LocalHospitalService.Api.Observation do
  @doc """
  Creates a Observation.
  """
  def create(%LocalHospitalService.Observations.Observation{} = observation) do
    LocalHospitalService.Api.post("observations", %{
      observation: LocalHospitalService.Observations.Observation.data(observation)
    })
    |> case do
      {:ok, data} -> {:ok, LocalHospitalService.Observations.Observation.struct!(nil, data)}
      {:error, reason} -> {:error, reason}
    end
  end
end
