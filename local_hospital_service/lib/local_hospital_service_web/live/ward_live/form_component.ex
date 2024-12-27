defmodule LocalHospitalServiceWeb.WardLive.FormComponent do
  use LocalHospitalServiceWeb, :live_component

  alias LocalHospitalService.Hospital

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage ward records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="ward-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="\description" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Ward</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{ward: ward} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Hospital.change_ward(ward))
     end)}
  end

  @impl true
  def handle_event("validate", %{"ward" => ward_params}, socket) do
    changeset = Hospital.change_ward(socket.assigns.ward, ward_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"ward" => ward_params}, socket) do
    save_ward(socket, socket.assigns.action, ward_params)
  end

  defp save_ward(socket, :edit, ward_params) do
    case Hospital.update_ward(socket.assigns.ward, ward_params) do
      {:ok, ward} ->
        notify_parent({:saved, ward})

        {:noreply,
         socket
         |> put_flash(:info, "Ward updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_ward(socket, :new, ward_params) do
    case Hospital.create_ward(ward_params) do
      {:ok, ward} ->
        notify_parent({:saved, ward})

        {:noreply,
         socket
         |> put_flash(:info, "Ward created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
