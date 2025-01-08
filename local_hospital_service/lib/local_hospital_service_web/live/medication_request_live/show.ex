defmodule LocalHospitalServiceWeb.MedicationRequestLive.Show do
  use LocalHospitalServiceWeb, :live_view

  alias LocalHospitalService.MedicationRequests

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:medication_request, MedicationRequests.get_medication_request!(id))}
  end

  defp page_title(:show), do: "Show Medication request"
  defp page_title(:edit), do: "Edit Medication request"
end
