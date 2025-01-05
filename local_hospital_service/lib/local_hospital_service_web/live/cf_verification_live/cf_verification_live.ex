defmodule LocalHospitalServiceWeb.CfVerificationLive do
  use LocalHospitalServiceWeb, :live_view
  alias LocalHospitalService.Api

  # MOUNT
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:cf_input, "")
      |> assign(:show_patient_not_found_dialog, false)

    {:ok, socket}
  end

  # RENDER: carichiamo la funzione "index" generata da CfVerificationHTML
  def render(assigns) do
    LocalHospitalServiceWeb.CfVerificationHTML.index(assigns)
  end

  # EVENTO: check_cf
  def handle_event("check_cf", %{"form" => %{"cf" => cf}}, socket) do
    case Api.get("patients/#{cf}") do
      {:ok, _data} ->
        # CF trovato
        {:noreply, push_redirect(socket, to: ~p"/encounters/new?patient_cf=#{cf}")}

      {:error, %{status_code: 404}} ->
        # CF non trovato
        {:noreply,
         socket
         |> assign(:cf_input, cf)
         |> assign(:show_patient_not_found_dialog, true)}

      {:error, reason} ->
        # Altri errori
        {:noreply,
         socket
         |> put_flash(:error, "Error: #{inspect(reason)}")
         |> assign(:cf_input, cf)
         |> assign(:show_patient_not_found_dialog, false)}
    end
  end

  # EVENTO: create_patient
  def handle_event("create_patient", _params, socket) do
    cf = socket.assigns.cf_input
    {:noreply, push_redirect(socket, to: ~p"/api/patients/new?prefill_cf=#{cf}")}
  end

  # EVENTO: cancel
  def handle_event("cancel", _params, socket) do
    # Reset allo stato iniziale
    {:noreply,
     socket
     |> assign(:show_patient_not_found_dialog, false)
     |> assign(:cf_input, "")
     |> push_patch(to: ~p"/cf_verification")}
  end
end
