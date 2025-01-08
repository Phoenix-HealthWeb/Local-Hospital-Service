defmodule LocalHospitalServiceWeb.MedicationRequestLive.Index do
  use LocalHospitalServiceWeb, :live_view

  alias LocalHospitalService.MedicationRequests.MedicationRequest

  @impl true
  def mount(_params, _session, socket) do
    # TODO: Retrieve the list of medication requests
    {:ok, stream(socket, :medication_request_collection, [])}
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
    {:noreply, stream_insert(socket, :medication_request_collection, medication_request)}
  end
end
