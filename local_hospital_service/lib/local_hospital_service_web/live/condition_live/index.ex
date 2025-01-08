defmodule LocalHospitalServiceWeb.ConditionLive.Index do
  use LocalHospitalServiceWeb, :live_view

  alias LocalHospitalService.Conditions.Condition

  @impl true
  def mount(_params, _session, socket) do
    # TODO: Retrieve all conditions
    {:ok, stream(socket, :conditions, [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Condition")
    |> assign(:condition, %Condition{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Conditions")
    |> assign(:condition, nil)
  end

  @impl true
  def handle_info({LocalHospitalServiceWeb.ConditionLive.FormComponent, {:saved, condition}}, socket) do
    {:noreply, stream_insert(socket, :conditions, condition)}
  end
end
