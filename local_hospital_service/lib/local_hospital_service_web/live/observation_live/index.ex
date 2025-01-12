defmodule LocalHospitalServiceWeb.ObservationLive.Index do

  use LocalHospitalServiceWeb, :live_view
  alias LocalHospitalService.Observations.Observation

  @impl true
  def mount(%{"wardId" => ward_name, "cf" => encounter_patient} = _params, _url, socket) do
    # Inizializza variabili con valori predefiniti
    # Recupera i dati del paziente
    patient = LocalHospitalService.Api.Patient.get_by_cf(encounter_patient)
    observations = Enum.reverse(Enum.map(patient.observations, & &1))

    {:ok,
     socket
     |> assign(:ward_name, ward_name)
     |> assign(:cf, encounter_patient)
     |> assign(:patient, patient)
     |> stream(:observations, observations)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Observation")
    |> assign(:observation, %Observation{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Observations")
    |> assign(:observation, nil)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Condition")
    |> assign(:observation, nil)
  end

  @impl true
  def handle_info({LocalHospitalServiceWeb.ObservationLive.FormComponent, {:saved, observation}}, socket) do
    {:noreply, stream_insert(socket, :observations, observation)}
  end
end
