defmodule LocalHospitalServiceWeb.ConditionLive.FormComponent do
  use LocalHospitalServiceWeb, :live_component

  alias LocalHospitalService.Conditions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage condition records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="condition-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:comment]} type="text" label="Comment" />
        <.input field={@form[:date_time]} type="datetime-local" label="Date time" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Condition</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{condition: condition} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Conditions.change_condition(condition))
     end)}
  end

  @impl true
  def handle_event("validate", %{"condition" => condition_params}, socket) do
    changeset = Conditions.change_condition(socket.assigns.condition, condition_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"condition" => condition_params}, socket) do
    save_condition(socket, socket.assigns.action, condition_params)
  end

  defp save_condition(socket, :edit, condition_params) do
    case Conditions.update_condition(socket.assigns.condition, condition_params) do
      {:ok, condition} ->
        notify_parent({:saved, condition})

        {:noreply,
         socket
         |> put_flash(:info, "Condition updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_condition(socket, :new, condition_params) do
    case Conditions.create_condition(condition_params) do
      {:ok, condition} ->
        notify_parent({:saved, condition})

        {:noreply,
         socket
         |> put_flash(:info, "Condition created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
