defmodule LocalHospitalServiceWeb.EncounterLive.Index do
  use LocalHospitalServiceWeb, :live_view

  alias LocalHospitalService.Hospital

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :encounters, Hospital.list_encounters())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Encounter")
    |> assign(:encounter, Hospital.get_encounter!(id))
  end
end
