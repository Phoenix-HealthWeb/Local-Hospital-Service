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

      <!-- TODO: Does not perform POST -->
      <.simple_form
        for={@form}
        id="consume_magic_link_form"
        phx-submit="consume_magic_link"
        method="post"
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
    form = to_form(%{"token" => token}, as: "magic_link")
    {:ok, assign(socket, form: form), temporary_assigns: [form: nil]}
  end
end
