defmodule Mix.Tasks.Populate.Wards do
  use Mix.Task

  @shortdoc "Populate the wards table with data, given a csv file as input"
  @moduledoc """
  This task populates the wards table with data, given a csv file as input.
  """

  require Logger

  @requirements ["app.start"]

  @impl Mix.Task
  def run([file_path]) do
    case File.read(file_path) do
      {:ok, file_content} ->
        file_content
        |> String.split("\n")
        |> Enum.map(&String.trim(&1))
        |> Enum.map(&String.split(&1, ","))
        |> Enum.map(&populate_ward/1)
        |> Enum.filter(&(&1 != nil))
        |> Enum.count()
        |> (&Logger.info("Total wards inserted: #{&1}")).()

      {:error, reason} ->
        raise "Error reading file #{file_path}: #{reason}"
    end
  end

  def run(_args) do
    raise """
    Usage:
      mix populate.wards <file_path>
    """
  end

  defp populate_ward([name, description]) do
    case LocalHospitalService.Repo.get_by(LocalHospitalService.Hospital.Ward, name: name) do
      nil ->
        ward = %LocalHospitalService.Hospital.Ward{}

        ward_changeset =
          LocalHospitalService.Hospital.Ward.changeset(ward, %{
            name: name,
            description: description
          })

        case LocalHospitalService.Repo.insert(ward_changeset) do
          {:ok, ward} ->
            ward

          {:error, changeset} ->
            Logger.warning("Error inserting ward #{name}: #{inspect(changeset.errors)}")
            nil
        end

      _ ->
        # Logger.info("Ward #{name} already exists")
        nil
    end
  end
end
