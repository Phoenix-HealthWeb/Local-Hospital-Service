defmodule LocalHospitalServiceWeb.LocalHospitalServiceWeb.DoctorLive.Indexxx do
  use LocalHospitalServiceWeb, :live_view

  alias LocalHospitalService.Hospital

  @impl true
  def mount(%{"wardId" => ward_name}, _session, socket) do
    #obtaining ward id from the ward_name parameter passed in the url request
    ward_id = ward_name_to_id(ward_name)

    if ward_id do
      #filtering of the encounters of the hospital based on ward parameter
      encounters = Hospital.list_encounters()
      |> Enum.filter(&(&1.ward_id == ward_id))

      #creation of priority queue with no duplicates
      priority_queue = create_priority_queue(encounters) |> Enum.reverse() |> Enum.uniq_by(& &1.ward)

      #extraction of the name of the ward from the priority queue
      ward_name_from_queue = get_ward_name_from_queue(priority_queue)
      {:ok,
       socket
       |> assign(:ward_name, ward_name_from_queue)
       |> stream(:encounters2, priority_queue)}
    else
      {:ok, socket |> assign(:error, "Ward not found")}
    end
  end

  #function to obtain ward name from the priority queue
  defp get_ward_name_from_queue([]), do: nil
  defp get_ward_name_from_queue([encounter | _]) do
    encounter.ward.name
  end

  @impl true
  def handle_params(%{"wardId" => ward_name} = _params, _url, socket) do
    ward_id = ward_name_to_id(ward_name)

    if ward_id do
      encounters = Hospital.list_encounters()
      |> Enum.filter(&(&1.ward_id == ward_id))

      priority_queue = create_priority_queue(encounters) |> Enum.reverse()

      {:noreply,
       socket
       |> assign(:ward_name, ward_name)
       |> stream(:encounters, priority_queue)}
    else
      {:noreply, socket |> assign(:error, "Ward not found")}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    encounter = Hospital.get_encounter!(id)
    {:ok, _} = Hospital.delete_encounter(encounter)

    ward_id = ward_name_to_id(socket.assigns.ward_name)

    updated_encounters = Hospital.list_encounters()
    |> Enum.filter(&(&1.ward_id == ward_id))

    priority_queue = create_priority_queue(updated_encounters) |> Enum.reverse()

    {:noreply, stream_delete(socket, :encounters, encounter)
               |> stream(:encounters, priority_queue)}
  end

  #function to obtain id of the ward from its name
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

  #simple function to create a list of wards available in the encounter list
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


  #function that count the amount of encounters for each ward available
  def count_ward_occurrences(encounters) do
    ward_ids = Enum.map(encounters, & &1.ward_id)
    occurrences = Enum.frequencies(ward_ids)

    Enum.map(occurrences, fn {ward_id, count} ->
      ward_name =
        encounters
        |> Enum.find(fn enc -> enc.ward_id == ward_id end)
        |> Map.get(:ward)
        |> Map.get(:name)
      count
    end)
  end

  @impl true
def handle_event("in_visit", %{"id" => id}, socket) do
  # Recupera l'encounter dal database
  encounter = Hospital.get_encounter!(id)

  # Aggiorna lo stato dell'encounter nel database
  {:ok, updated_encounter} =
    Hospital.update_encounter(encounter, %{status: "in_visit"})

  # Aggiorna il socket con l'encounter aggiornato
  {:noreply, stream_insert(socket, :encounters, updated_encounter)}
end
end
