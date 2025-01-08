defmodule LocalHospitalServiceWeb.ObservationLive.Index do
  use LocalHospitalServiceWeb, :live_view

  alias LocalHospitalService.Observations
  alias LocalHospitalService.Observations.Observation

  @impl true
  def mount(_params, _session, socket) do
    # TODO: Retrieve observations
    {:ok, stream(socket, :observation_collection, [])}
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
    |> assign(:page_title, "Listing Observation")
    |> assign(:observation, nil)
  end

  @impl true
  def handle_info({LocalHospitalServiceWeb.ObservationLive.FormComponent, {:saved, observation}}, socket) do
    {:noreply, stream_insert(socket, :observation_collection, observation)}
  end
end
