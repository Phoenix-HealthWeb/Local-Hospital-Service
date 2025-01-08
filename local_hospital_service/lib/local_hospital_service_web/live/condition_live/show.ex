defmodule LocalHospitalServiceWeb.ConditionLive.Show do
  use LocalHospitalServiceWeb, :live_view

  alias LocalHospitalService.Conditions

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:condition, Conditions.get_condition!(id))}
  end

  defp page_title(:show), do: "Show Condition"
  defp page_title(:edit), do: "Edit Condition"
end
