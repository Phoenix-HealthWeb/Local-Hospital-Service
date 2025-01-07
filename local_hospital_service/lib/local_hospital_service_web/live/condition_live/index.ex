defmodule LocalHospitalServiceWeb.ConditionLive.Index do
  use LocalHospitalServiceWeb, :live_view

  alias LocalHospitalService.Conditions
  alias LocalHospitalService.Conditions.Condition

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :conditions, Conditions.list_conditions())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Condition")
    |> assign(:condition, Conditions.get_condition!(id))
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

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    condition = Conditions.get_condition!(id)
    {:ok, _} = Conditions.delete_condition(condition)

    {:noreply, stream_delete(socket, :conditions, condition)}
  end
end
