defmodule LocalHospitalServiceWeb.EncounterLive.Index do
  use LocalHospitalServiceWeb, :live_view

  alias LocalHospitalService.Hospital
  alias LocalHospitalService.Hospital.Encounter

  def mount(_params, _session, socket) do
    wards = Repo.all(Ward) |> Enum.map(&{&1.name, &1.id})
    {:ok, assign(socket, wards: wards)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    wards = Hospital.list_wards()
    socket
    |> assign(:page_title, "Edit Encounter")
    |> assign(:encounter, Hospital.get_encounter!(id))
    |> assign(:wards, wards)
  end

  defp apply_action(socket, :new, _params) do
    wards = Hospital.list_wards()
    socket
    |> assign(:page_title, "New Encounter")
    |> assign(:encounter, %Encounter{})
    |> assign(:wards, wards)
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
