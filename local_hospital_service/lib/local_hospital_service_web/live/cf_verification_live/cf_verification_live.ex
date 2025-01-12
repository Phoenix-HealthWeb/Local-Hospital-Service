defmodule LocalHospitalServiceWeb.CfVerificationLive do
  use LocalHospitalServiceWeb, :live_view
  alias LocalHospitalService.Api

  # MOUNT
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:cf_input, "")
      |> assign(:show_patient_not_found_dialog, false)
      |> assign(:cf_error, nil)
    {:ok, socket}
  end

  def render(assigns) do
    LocalHospitalServiceWeb.CfVerificationHTML.index(assigns)
  end

  # Check_cf
  def handle_event("check_cf", %{"form" => %{"cf" => cf}}, socket) do
    if String.trim(cf) == "" do
      # CF not filled
      {:noreply,
       socket
       |> assign(:cf_error, "can't be blank!")
       |> assign(:cf_input, "")                 # clear field
       |> assign(:show_patient_not_found_dialog, false)}
    else
      case LocalHospitalService.Api.Patient.get_by_cf(cf) do
        nil ->
          {:noreply,
           socket
           |> assign(:cf_error, nil)
           |> assign(:cf_input, cf)
           |> assign(:show_patient_not_found_dialog, true)}
        _ ->
          {:noreply, push_navigate(socket, to: ~p"/nurses/encounters/new")}

      end
    end
  end

  # Create_patient
  def handle_event("create_patient", _params, socket) do
    cf = socket.assigns.cf_input
    {:noreply, redirect(socket, external: ~p"/nurses/patients/new")}
  end

  # Cancel
  def handle_event("cancel", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_patient_not_found_dialog, false)
     |> assign(:cf_input, "")
     |> push_patch(to: ~p"/nurses/cf_verification")}
  end
end
