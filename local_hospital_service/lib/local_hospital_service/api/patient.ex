defmodule LocalHospitalService.Api.Patient do
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

  @doc """
  Returns a patient by its CF, or nil otherwise.
  """
  def get_by_cf(cf) do
    LocalHospitalService.Api.get("patients/#{cf}?method=cf")
    |> case do
      {:ok, data} -> LocalHospitalService.Hospital.Patient.struct!(nil, data)
      {:error, _} -> nil
    end
  end
end
