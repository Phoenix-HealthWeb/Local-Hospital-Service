defmodule LocalHospitalServiceWeb.EncounterLive.FormComponent do
  use LocalHospitalServiceWeb, :live_component

  alias LocalHospitalService.Hospital

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage encounter records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="encounter-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:priority]} type="number" label="Priority" />
        <.input field={@form[:reason]} type="text" label="Reason" />
        <.input field={@form[:date_time]} type="datetime-local" label="Date time" />
        <.input field={@form[:patient]} type="text" label="Patient" />

        <!-- Ward select -->
        <.input
          field={@form[:ward_id]}
          type="select"
          options={@wards}
          prompt="Select a Ward"
          label="Ward"
        />

        <!-- Status select -->
        <.input
          field={@form[:status]}
          type="select"
          options={["queue", "in_visit"]}
          prompt="Select Status"
          label="Status"
        />

        <:actions>
          <.button phx-disable-with="Saving...">Save Encounter</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{encounter: encounter, wards: wards} = assigns, socket) do
    # Trasforma i ward in una lista di tuple {label, value}
    ward_options = Enum.map(wards, &{&1.name, &1.id})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:wards, ward_options) # Passa la lista di ward trasformata
     |> assign_new(:form, fn ->
       to_form(Hospital.change_encounter(encounter))
     end)}
  end

  @impl true
  def handle_event("validate", %{"encounter" => encounter_params}, socket) do
    changeset = Hospital.change_encounter(socket.assigns.encounter, encounter_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"encounter" => encounter_params}, socket) do
    save_encounter(socket, socket.assigns.action, encounter_params)
  end

  defp save_encounter(socket, :edit, encounter_params) do
    case Hospital.update_encounter(socket.assigns.encounter, encounter_params) do
      {:ok, encounter} ->
        notify_parent({:saved, encounter})

        {:noreply,
         socket
         |> put_flash(:info, "Encounter updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_encounter(socket, :new, encounter_params) do
    case Hospital.create_encounter(encounter_params) do
      {:ok, encounter} ->
        notify_parent({:saved, encounter})

        {:noreply,
         socket
         |> put_flash(:info, "Encounter created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
