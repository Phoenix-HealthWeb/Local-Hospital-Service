defmodule LocalHospitalServiceWeb.ObservationLive.FormComponent do
  use LocalHospitalServiceWeb, :live_component

  alias LocalHospitalService.Observations

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage observation records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="observation-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:date_time]} type="datetime-local" label="Date time" />
        <.input field={@form[:ward]} type="text" label="Ward" />
        <.input field={@form[:hospital_id]} type="text" label="Hospital" />
        <.input field={@form[:result]} type="text" label="Result" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Observation</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{observation: observation} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(LocalHospitalService.Observations.Observation.changeset(observation, %{}))
     end)}
  end

  @impl true
  def handle_event("validate", %{"observation" => observation_params}, socket) do
    changeset =
      LocalHospitalService.Observations.Observation.changeset(
        socket.assigns.observation,
        observation_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"observation" => observation_params}, socket) do
    save_observation(socket, socket.assigns.action, observation_params)
  end

  defp save_observation(socket, :new, observation_params) do
    :ok =
      LocalHospitalService.Observations.Observation.syncronize_to_ndb(
        LocalHospitalService.Observations.Observation.struct!(nil, observation_params)
      )

    notify_parent({:saved, observation_params})

    {:noreply,
     socket
     |> put_flash(:info, "Observation created successfully")
     |> push_patch(to: socket.assigns.patch)}
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
