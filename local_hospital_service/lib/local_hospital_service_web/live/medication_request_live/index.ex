defmodule LocalHospitalServiceWeb.MedicationRequestLive.Index do
  use LocalHospitalServiceWeb, :live_view

  alias LocalHospitalService.MedicationRequests.MedicationRequest

  @impl true
  def mount(%{"wardId" => ward_name, "cf" => encounter_patient} = _params, _url, socket) do

    patient = LocalHospitalService.Api.Patient.get_by_cf(encounter_patient)
    medication_requests = Enum.reverse(Enum.map(patient.medication_requests, & &1))

    {:ok,
     socket
     |> assign(:ward_name, ward_name)
     |> assign(:cf, encounter_patient)
     |> stream(:medication_requests, medication_requests)
     |> assign(:patient, patient)
  }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Medication request")
    |> assign(:medication_request, %MedicationRequest{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Medication request")
    |> assign(:medication_request, nil)
  end

  @impl true
  def handle_info({LocalHospitalServiceWeb.MedicationRequestLive.FormComponent, {:saved, medication_request}}, socket) do
    {:noreply, stream_insert(socket, :medication_requests, medication_request)}
  end
end
