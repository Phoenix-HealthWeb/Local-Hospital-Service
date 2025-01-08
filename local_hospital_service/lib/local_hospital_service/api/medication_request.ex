defmodule LocalHospitalService.Api.MedicationRequest do
  @doc """
  Creates a MedicationRequest.
  """
  def create(%LocalHospitalService.MedicationRequests.MedicationRequest{} = medication_request) do
    LocalHospitalService.Api.post("medication_requests", %{
      medication_request:
        LocalHospitalService.MedicationRequests.MedicationRequest.data(medication_request)
    })
    |> case do
      {:ok, data} ->
        {:ok, LocalHospitalService.MedicationRequests.MedicationRequest.struct!(nil, data)}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
