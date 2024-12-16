defmodule LocalHospitalService.Api do
  @moduledoc """
  Used to perform HTTP requests to the NDB Rest APIs.
  """

  require Logger

  def get(path) do
    url = get_url(path)

    case HTTPoison.get(url, get_headers()) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("GET #{url} failed with status #{status_code}")
        {:error, %{status_code: status_code, body: body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Request error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def post(path, %{} = body) do
    url = get_url(path)
    stringified_body = Jason.encode!(body)

    case HTTPoison.post(url, stringified_body, get_headers(), []) do
      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

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
      {"Accept", "application/json"}
    ]
  end

  defp get_url(path) do
    Application.get_env(:local_hospital_service, __MODULE__)[:ndb_url] <> path
  end
end
