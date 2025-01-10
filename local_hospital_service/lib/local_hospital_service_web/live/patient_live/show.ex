defmodule LocalHospitalServiceWeb.PatientLive.Show do
  use LocalHospitalServiceWeb, :live_view

  alias LocalHospitalService.Hospital
  require Logger  # Aggiungi il require Logger per poter utilizzare Logger

  @impl true
  def mount(_params, _session, socket) do


    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    patient = Hospital.get_patient!(id)

    # Aggiungi il log dei dati del paziente
    Logger.debug("Dati del paziente: #{inspect(patient)}")

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:patient, patient)}
  end

  defp page_title(:show), do: "Show Patient"
  defp page_title(:edit), do: "Edit Patient"
end
