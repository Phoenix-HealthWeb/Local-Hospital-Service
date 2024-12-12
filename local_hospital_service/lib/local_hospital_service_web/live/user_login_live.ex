defmodule LocalHospitalServiceWeb.UserLoginLive do
alias LocalHospitalService.Accounts
  use LocalHospitalServiceWeb, :live_view

  def render(assigns) do
    ~H"""
    <div :if={@status == :input_email} class="mx-auto max-w-sm">
      <.header class="text-center">
        Log in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="magic_link_form"
        action={~p"/users/log_in"}
        phx-update="ignore"
        phx-submit="send-magic-link"
        class="my-0 py-0"
      >
        <.input field={@form[:email]} type="email" label="Email" required />
        <:actions>
          <.button
            class="w-full flex place-content-center place-items-center gap-2"
            phx-disable-with="Sending email..."
          >
            Send me a link <.icon name="hero-envelope" />
          </.button>
        </:actions>
      </.simple_form>
    </div>

    <div :if={@status == :link_sent} class="mx-auto">
      <.header class="text-center">
        Check your email!
        <:subtitle>
          If <span class="font-semibold text-brand"><%= @target_email %></span> is in our database, you will receive a one-time link to login.
        </:subtitle>
      </.header>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form, status: :input_email), temporary_assigns: [form: form]}
  end

  @doc """
  Handle the "send-magic-link" event.
  Consists in sending a magic link to the user's email so to perform login.
  """
  def handle_event("send-magic-link", params, socket) do
    %{"user" => %{"email" => email}} = params

    Accounts.generate_magic_link(email)

    socket =
      socket
      |> assign(:status, :link_sent)
      |> assign(:target_email, email)

    {:noreply, socket}
  end
end
