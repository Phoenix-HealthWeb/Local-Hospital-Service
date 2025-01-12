defmodule LocalHospitalService.Api.Condition do
  @doc """
  Creates a Condition.
  """
  def create(%LocalHospitalService.Conditions.Condition{} = condition) do
    # Ispezioniamo i dati prima di inviarli
    data = %{
      condition: LocalHospitalService.Conditions.Condition.data(condition)
    }

    IO.inspect(data, label: "POST Request Data")

    # Effettua la chiamata post
    LocalHospitalService.Api.post("conditions", data)
    |> case do
      {:ok, data} -> {:ok, LocalHospitalService.Conditions.Condition.struct!(nil, data)}
      {:error, reason} -> {:error, reason}
    end
  end
end
