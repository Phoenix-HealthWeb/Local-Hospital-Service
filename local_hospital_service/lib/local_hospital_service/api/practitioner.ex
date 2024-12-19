defmodule LocalHospitalService.Api.Practitioner do

  @doc """
  Returns a practitioner by its email, or nil otherwise.
  """
  def get_by_email(email) do
    LocalHospitalService.Api.get("practitioners/search/#{email}")
    |> case do
      {:ok, data} -> LocalHospitalService.Accounts.User.struct!(data)
      {:error, _} -> nil
    end
  end
end
