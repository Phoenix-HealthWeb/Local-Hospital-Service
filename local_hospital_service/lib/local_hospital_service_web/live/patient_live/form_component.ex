defmodule LocalHospitalServiceWeb.PatientLive.FormComponent do
  use LocalHospitalServiceWeb, :live_component

  alias LocalHospitalService.Hospital

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage patient records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="patient-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:cf]} type="text" label="Cf" />
        <.input field={@form[:firstname]} type="text" label="Firstname" />
        <.input field={@form[:lastname]} type="text" label="Lastname" />
        <.input field={@form[:date_of_birth]} type="date" label="Date of birth" />
        <.input field={@form[:gender]} type="text" label="Gender" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Patient</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{patient: patient} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Hospital.change_patient(patient))
     end)}
  end

  @impl true
  def handle_event("validate", %{"patient" => patient_params}, socket) do
    changeset = Hospital.change_patient(socket.assigns.patient, patient_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"patient" => patient_params}, socket) do
    save_patient(socket, socket.assigns.action, patient_params)
  end

  defp save_patient(socket, :edit, patient_params) do
    case Hospital.update_patient(socket.assigns.patient, patient_params) do
      {:ok, patient} ->
        notify_parent({:saved, patient})

        {:noreply,
         socket
         |> put_flash(:info, "Patient updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_patient(socket, :new, patient_params) do
    case Hospital.create_patient(patient_params) do
      {:ok, patient} ->
        notify_parent({:saved, patient})

        {:noreply,
         socket
         |> put_flash(:info, "Patient created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
