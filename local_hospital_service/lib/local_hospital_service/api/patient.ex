defmodule LocalHospitalService.Api.Patient do
  require Logger

  @doc """
  Creates a Patient if its CF does not already exist.
  """
  def create(%LocalHospitalService.Hospital.Patient{} = patient) do
    LocalHospitalService.Api.post("patients", %{
      patient: LocalHospitalService.Hospital.Patient.data(patient)
    })
    |> case do
      {:ok, data} -> LocalHospitalService.Hospital.Patient.struct!(nil, data)
      {:error, _} -> nil
    end
  end
end
