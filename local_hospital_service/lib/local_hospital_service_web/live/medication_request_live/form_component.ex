defmodule LocalHospitalServiceWeb.MedicationRequestLive.FormComponent do
  use LocalHospitalServiceWeb, :live_component


  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage medication_request records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="medication_request-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:date_time]} type="datetime-local" label="Date time" />
        <.input field={@form[:expiration_date]} type="date" label="Expiration date" />
        <.input field={@form[:medication]} type="text" label="Medication" />
        <.input field={@form[:posology]} type="text" label="Posology" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Medication request</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{medication_request: medication_request} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(
         LocalHospitalService.MedicationRequests.MedicationRequest.changeset(medication_request, %{})
       )
     end)}
  end

  @impl true
  def handle_event("validate", %{"medication_request" => medication_request_params}, socket) do
    changeset =
      LocalHospitalService.MedicationRequests.MedicationRequest.changeset(
        socket.assigns.medication_request,
        medication_request_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"medication_request" => medication_request_params}, socket) do
    save_medication_request(socket, socket.assigns.action, medication_request_params)
  end

  defp save_medication_request(socket, :new, medication_request_params) do
    :ok =
      LocalHospitalService.MedicationRequests.MedicationRequest.syncronize_to_ndb(
        medication_request_params
      )

    notify_parent({:saved, medication_request_params})

    {:noreply,
     socket
     |> put_flash(:info, "Medication request created successfully")
     |> push_patch(to: socket.assigns.patch)}
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
