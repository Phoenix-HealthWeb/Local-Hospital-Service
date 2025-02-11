defmodule LocalHospitalService.Api do
  @moduledoc """
  Used to perform HTTP requests to the NDB Rest APIs.
  """

  require Logger

  @doc """
  Performs a GET request to the NDB Rest API.
  """
  def get(path) do
    url = get_url(path)
    headers = get_headers()

    Logger.debug("Generated URL: #{url}")
    Logger.debug("Request Headers: #{inspect(headers)}")

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body, keys: :atoms) do
          {:ok, %{data: data}} -> {:ok, data}
          {:ok, other} ->
            Logger.error("Unexpected response structure: #{inspect(other)}")
            {:error, :unexpected_response}
          {:error, decode_error} ->
            Logger.error("JSON decoding error: #{inspect(decode_error)}")
            {:error, :invalid_json}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("GET #{url} failed with status #{status_code}: #{body}")
        {:error, %{status_code: status_code, body: body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("GET #{url} request error: #{inspect(reason)}")
        {:error, reason}
    end
  end


  @doc """
    Performs a POST request to the NDB Rest API.

    Example of call: `LocalHospitalService.Api.post("practitioners", %{practitioner: %{email: "example@gmail.com", date_of_birth: "2000-12-26", forename: "John", surname: "Smith", qualification: "Nurse"}})`
  """
  def post(path, %{} = body) do
    url = get_url(path)
    stringified_body = Jason.encode!(body)

    case HTTPoison.post(url, stringified_body, get_headers(), []) do
      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
        %{data: data} = Jason.decode!(body, keys: :atoms)
        {:ok, data}

      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        %{data: data} = Jason.decode!(body, keys: :atoms)
        {:ok, data}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("POST #{url} failed with status #{status_code}")
        {:error, %{status_code: status_code, body: body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Request error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp get_headers() do
    [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"},
      {"x-hospital-id", Application.get_env(:local_hospital_service, __MODULE__)[:ndb_api_hospital_id]},
      {"x-api-key", Application.get_env(:local_hospital_service, __MODULE__)[:ndb_api_key]}
    ]
  end

  defp get_url(path) do
    # Removes the leading slash from the path, only if present
    # and prepends the full url
    path
    |> String.replace(~r{^/}, "")
    |> (&(Application.get_env(:local_hospital_service, __MODULE__)[:ndb_url] <> &1)).()
  end
end
