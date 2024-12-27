defmodule LocalHospitalServiceWeb.EncounterLive.Index do
  use LocalHospitalServiceWeb, :live_view

  alias LocalHospitalService.Hospital

  @impl true
  def mount(_params, _session, socket) do
    # Precaricamento degli encounter con le ward
    encounters = Hospital.list_encounters()

    # Conversione delle ward in una lista di opzioni per il form
    wards = Hospital.list_wards() |> Enum.map(&{&1.name, &1.id})

    {:ok,
     socket
     |> assign(:wards, wards)
     |> stream(:encounters, encounters)}
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
    # Elimina l'encounter e aggiorna il flusso
    encounter = Hospital.get_encounter!(id)
    {:ok, _} = Hospital.delete_encounter(encounter)

    {:noreply, stream_delete(socket, :encounters, encounter)}
  end
end
