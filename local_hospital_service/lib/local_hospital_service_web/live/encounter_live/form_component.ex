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
        id={"encounter-form-#{@encounter.id || "new"}"}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:priority]} type="number" label="Priority" />
        <.input field={@form[:reason]} type="text" label="Reason" />
        <.input field={@form[:date_time]} type="datetime-local" label="Date time" />
        <.input field={@form[:patient]} type="text" label="Patient" />

        <!-- Ward select -->
        <.input field={@form[:ward_id]} type="select" options={@wards} prompt="Select a Ward" label="Ward" />

        <!-- Status select -->
        <.input field={@form[:status]} type="select" options={["queue", "in_visit"]} prompt="Select Status" label="Status" />

        <:actions>
          <.button phx-disable-with="Saving...">Save Encounter</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{encounter: encounter, wards: wards} = assigns, socket) do
    IO.inspect(wards, label: "Wards received in form component")
    IO.inspect(encounter, label: "Encounter received in form component")

    changeset = Hospital.change_encounter(encounter)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, to_form(changeset))}

  end

  @impl true
  def handle_event("validate", %{"encounter" => encounter_params}, socket) do
    IO.inspect(encounter_params, label: "Encounter params during validation")

    sanitized_params =
      encounter_params
      |> Enum.reject(fn {key, _value} -> String.starts_with?(key, "_unused_") end)
      |> Enum.into(%{})

    changeset =
      socket.assigns.encounter
      |> Hospital.change_encounter(sanitized_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("save", %{"encounter" => encounter_params}, socket) do
    sanitized_params =
      encounter_params
      |> Enum.reject(fn {key, _value} -> String.starts_with?(key, "_unused_") end)
      |> Enum.into(%{})

    case save_encounter(socket.assigns.action, socket.assigns.encounter, sanitized_params) do
      {:ok, encounter} ->
        send(self(), {:saved, encounter})

        {:noreply,
         socket
         |> put_flash(:info, "Encounter saved successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, changeset} ->
        IO.inspect(changeset.errors, label: "Changeset Errors")
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_encounter(:new, _encounter, encounter_params) do
    Hospital.create_encounter(encounter_params)
  end

  defp save_encounter(:edit, encounter, encounter_params) do
    Hospital.update_encounter(encounter, encounter_params)
  end
end
