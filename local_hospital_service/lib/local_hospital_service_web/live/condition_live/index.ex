defmodule LocalHospitalServiceWeb.ConditionLive.Index do
  use LocalHospitalServiceWeb, :live_view

  alias LocalHospitalService.Conditions.Condition

  @impl true
  def mount(%{"wardId" => ward_name, "cf" => encounter_patient} = _params, _url, socket) do
    # Usa `case` per verificare i parametri necessari


      # Esegui la logica se i parametri sono presenti
      patient = LocalHospitalService.Api.Patient.get_by_cf(encounter_patient)
      conditions = Enum.reverse(Enum.map(patient.conditions, & &1))

      # Restituisci il socket con le nuove informazioni
      {:ok,
        socket
        |> assign(:ward_name, ward_name)
        |> assign(:cf, encounter_patient)
        |> assign(:conditions, conditions)
        |> assign(:patient, patient)
        |> stream(:conditions, conditions)}


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

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Condition")
    |> assign(:condition, nil)
  end

  @impl true
  def handle_info({LocalHospitalServiceWeb.ConditionLive.FormComponent, {:saved, condition}}, socket) do
    {:noreply, stream_insert(socket, :conditions, condition)}
  end
end
