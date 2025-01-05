defmodule LocalHospitalServiceWeb.DoctorLive.Index do
  use LocalHospitalServiceWeb, :live_view

  alias LocalHospitalService.Hospital

  @impl true
def mount(_params, _session, socket) do
  # Precaricamento degli encounter con le ward
  encounters = Hospital.list_encounters()
  priority_queue = create_priority_queue(encounters)

  priority_queue = Enum.reverse(priority_queue)

  # Conversione delle ward in una lista di opzioni per il form
  wards = Hospital.list_wards() |> Enum.map(&{&1.name, &1.id})

  final = list_ward_names_from_ids(wards)


  # Conteggio delle occorrenze per ogni ward

  nice = count_ward_occurrences(priority_queue)


  {:ok,
   socket
   |> assign(:wards, wards)
   |> assign(:ward_ids, final)
   |> assign(:nice, nice)
   |> stream(:encounters, priority_queue)}
end


  def list_ward_ids(encounters) do
    encounters
    |> Enum.map(& &1.ward_id)
  end

  def count_ward_occurrences(encounters) do
    # Ottieni tutti i ward_id presenti negli encounters
    ward_ids = Enum.map(encounters, & &1.ward_id)

    # Conta le occorrenze di ciascun ward_id
    occurrences = Enum.frequencies(ward_ids)

    # Associa i conteggi ai nomi delle ward
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
    # Assicurati che la priorità sia un numero, poi ordina in ordine crescente
    Enum.sort_by(encounters, & &1.priority)

  end

  @spec list_ward_names_from_ids(any()) :: list()
  def list_ward_names_from_ids(wards) do
    # Crea una lista dei nomi delle ward che sono presenti in ward_ids
    encounters = Hospital.list_encounters()
    ward_ids = list_ward_ids(encounters)

    ward_names =
      wards
      |> Enum.filter(fn {name, id} -> id in ward_ids end)  # Filtra le ward che sono nei ward_ids
      |> Enum.map(fn {name, _id} -> name end)  # Estrai solo i nomi delle ward

    ward_names
  end




  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    # Carica l'encounter con la ward precaricata
    encounter = Hospital.get_encounter!(id)
    IO.inspect(encounter.ward, label: "Loaded Ward in Edit Action")

    socket
    |> assign(:page_title, "Edit Encounter")
    |> assign(:encounter, encounter)
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
  # Trova ed elimina l'encounter
  encounter = Hospital.get_encounter!(id)
  {:ok, _} = Hospital.delete_encounter(encounter)

  # Rimuovi l'encounter dalla lista visibile
  {:noreply, stream_delete(socket, :encounters, encounter)}
end

@impl true
def handle_event("add", %{"encounter" => encounter_params}, socket) do
  # Crea un nuovo encounter
  case Hospital.create_encounter(encounter_params) do
    {:ok, new_encounter} ->
      updated_encounter = new_encounter

      # Aggiungi l'encounter alla lista visibile
      {:noreply, stream_insert(socket, :encounters, updated_encounter)}

    {:error, changeset} ->
      # Gestisci gli errori, ad esempio, mostrando un messaggio all'utente
      {:noreply, socket |> assign(:error, changeset)}
  end
end

@impl true
def handle_event("navigate_to_ward", %{"ward_id" => ward_id}, socket) do
  # Verifica se il ward_id esiste e reindirizza alla route corrispondente
  {:noreply, push_redirect(socket, to: Routes.doctor_ward_path(socket, :index, ward_id))}
end


end
