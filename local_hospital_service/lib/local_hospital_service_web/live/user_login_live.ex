defmodule LocalHospitalServiceWeb.UserLoginLive do
  alias LocalHospitalService.Accounts
  use LocalHospitalServiceWeb, :live_view

  @show_auto_redirect_to_magic_link Application.compile_env(
                                      :local_hospital_service,
                                      :show_auto_redirect_to_magic_link,
                                      false
                                    )

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
        <!-- DEV ONLY: auto redirect to magic link page if enabled in config -->
        <:actions :if={@show_auto_redirect_to_magic_link}>
          <.input
            field={@form[:redirect_to_magic_link]}
            type="checkbox"
            label="DEV ONLY: auto redirect to magic link page"
          />
        </:actions>

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
          If <span class="font-semibold text-brand"><%= @target_email %></span>
          is in our database, you will receive a one-time link to login.
        </:subtitle>
      </.header>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")

    {:ok,
     assign(socket,
       form: form,
       status: :input_email,
       skip_account_header: true,
       show_auto_redirect_to_magic_link: @show_auto_redirect_to_magic_link
     ), temporary_assigns: [form: form]}
  end

  @doc """
  Handle the "send-magic-link" event.
  Consists in sending a magic link to the user's email so to perform login.
  """
  def handle_event("send-magic-link", params, socket) do
    %{"user" => %{"email" => email}} = params

    token = Accounts.generate_magic_link(email)

    socket =
      socket
      |> assign(:status, :link_sent)
      |> assign(:target_email, email)

    # Only if allowed and requested, auto-redirect to the magic link page without the need to open the email link
    socket =
      if token && @show_auto_redirect_to_magic_link &&
           params["user"]["redirect_to_magic_link"] == "true" do
        push_navigate(socket,
          to: ~p"/users/log_in/#{token}"
        )
      else
        socket
      end

    {:noreply, socket}
  end
end
