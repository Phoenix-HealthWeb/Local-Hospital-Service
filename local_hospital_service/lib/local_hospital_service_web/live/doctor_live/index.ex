defmodule LocalHospitalServiceWeb.LocalHospitalServiceWeb.DoctorLive.Index do
  use LocalHospitalServiceWeb, :live_view
  alias LocalHospitalService.Hospital

  @impl true
  @spec mount(any(), any(), map()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do

    # Retrieving all encounters of this hospital
    encounters = Hospital.list_encounters()

    #creation of a priority queue based on priority parameter of encounters and sorting it
    priority_queue = create_priority_queue(encounters)
    priority_queue = Enum.reverse(priority_queue)

    #conversion from ward ids to ward names
    wards = Hospital.list_wards() |> Enum.map(&{&1.name, &1.id})
    final = list_ward_names_from_ids(wards)

    #counting patients for each ward
    nice = count_ward_occurrences(priority_queue)

    {:ok,
    socket
    |> assign(:wards, wards)
    |> assign(:ward_ids, final)
    |> assign(:nice, nice)
    |> stream(:encounters, priority_queue)}
  end

  #function that lists all wards available in the present encounters
  def list_ward_ids(encounters) do
    encounters
    |> Enum.map(& &1.ward_id)
  end

  #function that count the amount of encounters for each ward available
  def count_ward_occurrences(encounters) do

    ward_ids = Enum.map(encounters, & &1.ward_id)

    occurrences = Enum.frequencies(ward_ids)

    #association between wards and their counters
    Enum.map(occurrences, fn {ward_id, count} ->
      ward_name =
        encounters
        |> Enum.find(fn enc -> enc.ward_id == ward_id end)
        |> Map.get(:ward)
        |> Map.get(:name)

      count
    end)
  end

  def create_priority_queue(encounters) do
    Enum.sort_by(encounters, & &1.priority)
  end

  #simple function to create a list of wards available in the encounter list
  @spec list_ward_names_from_ids(any()) :: list()
  def list_ward_names_from_ids(wards) do
    encounters = Hospital.list_encounters()
    ward_ids = list_ward_ids(encounters)
    ward_names =
      wards
      |> Enum.filter(fn {name, id} -> id in ward_ids end)
      |> Enum.map(fn {name, _id} -> name end)
    ward_names
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
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

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Encounter")
    |> assign(:encounter, %Hospital.Encounter{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Encounters")
    |> assign(:encounter, nil)
  end

  @impl true
  def handle_info({LocalHospitalServiceWeb.EncounterLive.FormComponent, {:saved, encounter}}, socket) do
    {:noreply, stream_insert(socket, :encounters, encounter)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    encounter = Hospital.get_encounter!(id)
    {:ok, _} = Hospital.delete_encounter(encounter)
    {:noreply, stream_delete(socket, :encounters, encounter)}
  end


end
