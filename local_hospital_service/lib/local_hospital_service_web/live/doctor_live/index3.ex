defmodule LocalHospitalServiceWeb.LocalHospitalServiceWeb.DoctorLive.Index3 do
  use LocalHospitalServiceWeb, :live_view

  alias LocalHospitalService.Hospital

  @impl true
  def mount(%{"wardId" => ward_name}, _session, socket) do
    ward_id = ward_name_to_id(ward_name)

    if ward_id do
      encounters = Hospital.list_encounters()
      |> Enum.filter(&(&1.ward_id == ward_id))

      priority_queue = create_priority_queue(encounters) |> Enum.reverse() |> Enum.uniq_by(& &1.ward)
      ward_name_from_queue = get_ward_name_from_queue(priority_queue)

      {:ok,
      socket
      |> assign(:ward_name, ward_name_from_queue)
      |> stream(:encounters2, priority_queue)}
    else
      {:ok, socket |> assign(:error, "Ward not found")}
    end
  end

  defp get_ward_name_from_queue([]), do: nil
  defp get_ward_name_from_queue([encounter | _]) do
    encounter.ward.name
  end

  #function to manage the change of parameters like ward name or cf of the patient in the url request
  @impl true
  def handle_params(%{"wardId" => ward_name, "cf" => encounter_patient} = _params, _url, socket) do
    ward_id = ward_name_to_id(ward_name)

    encounters = Hospital.list_encounters()
    |> Enum.filter(&(&1.ward_id == ward_id))
    |> Enum.filter(&(&1.status == "in_visit"))
    |> Enum.filter(&(&1.patient == encounter_patient))

    #request to get from the api the details about the patient giving its patient field
    patient = LocalHospitalService.Api.Patient.get_by_cf(encounter_patient)

    #creation of lists of conditions, observations, medication_requests obtained from the patient
    conditions =
      if patient do
        Enum.reverse(Enum.map(patient.conditions, & &1))
      else
        []
      end

    observations =
      if patient do
        Enum.reverse(Enum.map(patient.observations, & &1))
      else
        []
      end

    medication_requests =
      if patient do
        Enum.reverse(Enum.map(patient.medication_requests, & &1))
      else
        []
      end

    reason =
      case List.first(encounters) do
        nil -> nil
        encounter -> encounter.reason
      end

    encounter =
      case List.first(encounters) do
        nil -> nil
        encounter -> encounter.patient
      end

    {:noreply,
      socket
      |> assign(:encounter, encounter)
      |> assign(:ward, ward_name)
      |> assign(:reason, reason)
      |> assign(:patient, patient)
      |> stream(:conditions, conditions)
      |> stream(:observations, observations)
      |> stream(:medication_requests, medication_requests)}
  end

  defp ward_name_to_id(ward_name) do
    Hospital.list_wards()
    |> Enum.find(fn ward -> String.downcase(ward.name) == String.downcase(ward_name) end)
    |> case do
      nil -> nil
      ward -> ward.id
    end
  end

  def create_priority_queue(encounters) do
    Enum.sort_by(encounters, & &1.priority)
  end

  def list_ward_names_from_ids(wards) do
    encounters = Hospital.list_encounters()
    ward_ids = list_ward_ids(encounters)

    wards
    |> Enum.filter(fn {name, id} -> id in ward_ids end)
    |> Enum.map(fn {name, _id} -> name end)
  end

  def list_ward_ids(encounters) do
    encounters |> Enum.map(& &1.ward_id)
  end
end
