defmodule LocalHospitalServiceWeb.DoctorLive.Index3 do
  use LocalHospitalServiceWeb, :live_view

  alias LocalHospitalService.Hospital

  @impl true
  def mount(%{"wardId" => ward_name}, _session, socket) do
    # Ottieni l'ID della ward dal nome
    ward_id = ward_name_to_id(ward_name)

    if ward_id do
      # Filtra gli encounters usando l'ID della ward
      encounters = Hospital.list_encounters()
      |> Enum.filter(&(&1.ward_id == ward_id))

      # Crea la priority queue e rimuove i duplicati
      priority_queue = create_priority_queue(encounters) |> Enum.reverse() |> Enum.uniq_by(& &1.ward)

      # Estrai il nome della ward dalla priority queue
      ward_name_from_queue = get_ward_name_from_queue(priority_queue)

      # Conversione delle ward in una lista di opzioni per il form
      wards = Hospital.list_wards() |> Enum.map(&{&1.name, &1.id})

      {:ok,
       socket
       |> assign(:ward_name, ward_name_from_queue) # Assegna il nome della ward
       |> stream(:encounters2, priority_queue)}

    else
      # Se il nome non è valido, gestisci l'errore
      {:ok, socket |> assign(:error, "Ward not found")}
    end
  end

  # Funzione per ottenere il nome della ward dalla priority queue
  defp get_ward_name_from_queue([]), do: nil
  defp get_ward_name_from_queue([encounter | _]) do
    encounter.ward.name
  end

  @impl true
  def handle_params(%{"wardId" => ward_name, "cf" => encounter_patient} = _params, _url, socket) do
    ward_id = ward_name_to_id(ward_name)

    if ward_id do
      # Filtra gli encounters usando l'ID della ward e il paziente
      encounters = Hospital.list_encounters()
      |> Enum.filter(&(&1.ward_id == ward_id))
      |> Enum.filter(&(&1.status == "in_visit"))
      |> Enum.filter(&(&1.patient == encounter_patient))

      # Recupera i dati del paziente
      patient = LocalHospitalService.Api.Patient.get_by_cf(encounter_patient)

      if patient do
        # Precarica le condizioni, osservazioni e richieste di farmaci del paziente
        conditions = Enum.reverse(Enum.map(patient.conditions, & &1))
        observations = Enum.reverse(Enum.map(patient.observations, & &1))
        medication_request = Enum.reverse(Enum.map(patient.medication_requests, & &1))

        quack =
          case List.first(encounters) do
            nil -> nil # Nessun elemento trovato
            encounter -> encounter.reason
          end


        {:noreply,
         socket
         |> assign(:encounter, quack)
         |> assign(:patient, patient)
         |> assign(:conditions, conditions)
         |> assign(:observations, observations)
         |> assign(:medication_request, medication_request)}
      else
        {:noreply,
         socket
         |> assign(:error, "Patient not found")
         |> assign(:patient, nil)
         |> assign(:conditions, nil)
         |> assign(:observations, nil)
         |> assign(:medication_request, nil)}
      end
    end
  end

# Funzione per ottenere il paziente tramite ID
defp get_patient(patient_id) do
  if patient_id do
    Repo.get(Patient, patient_id)  # Recupera il paziente tramite ID
  else
    nil
  end
end

# Funzione per ottenere il practitioner tramite ID
defp get_practitioner(practitioner_id) do
  if practitioner_id do
    Repo.get(Practitioner, practitioner_id)  # Recupera il practitioner tramite ID
  else
    nil
  end
end


  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    # Trova ed elimina l'encounter
    encounter = Hospital.get_encounter!(id)
    {:ok, _} = Hospital.delete_encounter(encounter)

    # Aggiorna la lista degli encounters filtrati
    ward_id = ward_name_to_id(socket.assigns.ward_name)

    updated_encounters = Hospital.list_encounters()
    |> Enum.filter(&(&1.ward_id == ward_id))

    priority_queue = create_priority_queue(updated_encounters) |> Enum.reverse()

    {:noreply, stream_delete(socket, :encounters, encounter)
               |> stream(:encounters, priority_queue)}
  end

  @impl true
  def handle_event("add", %{"encounter" => encounter_params}, socket) do
    # Crea un nuovo encounter
    case Hospital.create_encounter(encounter_params) do
      {:ok, new_encounter} ->
        # Verifica se il nuovo encounter appartiene al ward_name corrente
        if new_encounter.ward_id == ward_name_to_id(socket.assigns.ward_name) do
          {:noreply, stream_insert(socket, :encounters, new_encounter)}
        else
          {:noreply, socket}
        end

      {:error, changeset} ->
        {:noreply, socket |> assign(:error, changeset)}
    end
  end

  # Funzione per ottenere l'ID della ward dal suo nome
  defp ward_name_to_id(ward_name) do
    Hospital.list_wards()
    |> Enum.find(fn ward -> String.downcase(ward.name) == String.downcase(ward_name) end)
    |> case do
      nil -> nil
      ward -> ward.id
    end
  end

  # Altre funzioni rimangono invariate

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
end
