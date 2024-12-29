defmodule LocalHospitalServiceWeb.WardLive.Index do
  use LocalHospitalServiceWeb, :live_view

  alias LocalHospitalService.Hospital
  alias LocalHospitalService.Hospital.Ward

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :wards, Hospital.list_wards())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Ward")
    |> assign(:ward, Hospital.get_ward!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Ward")
    |> assign(:ward, %Ward{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Wards")
    |> assign(:ward, nil)
  end

  @impl true
  def handle_info({LocalHospitalServiceWeb.WardLive.FormComponent, {:saved, ward}}, socket) do
    {:noreply, stream_insert(socket, :wards, ward)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    ward = Hospital.get_ward!(id)
    {:ok, _} = Hospital.delete_ward(ward)

    {:noreply, stream_delete(socket, :wards, ward)}
  end
end
