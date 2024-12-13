defmodule LocalHospitalServiceWeb.UserLoginMagicLinkLive do
  use LocalHospitalServiceWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        You're nearly done!
        <:subtitle>
          Please click below to sign in
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="consume_magic_link_form"
        method="post"
        phx-submit="consume_magic_link"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=magic_link"}
      >
        <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
        <:actions>
          <.button phx-disable-with="Signin in..." class="w-full">Sign in</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    form = to_form(%{"token" => token})

    {:ok, assign(socket, form: form, trigger_submit: false), temporary_assigns: [form: nil]}
  end

  @doc """
  Called when the user submits the form.
  It triggers the relative POST request defined on the form
  """
  def handle_event("consume_magic_link", %{"token" => _}, socket) do
    {:noreply, assign(socket, trigger_submit: true)}
  end
end
