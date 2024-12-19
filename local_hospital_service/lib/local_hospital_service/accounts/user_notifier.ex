defmodule LocalHospitalService.Accounts.UserNotifier do
  import Swoosh.Email

  alias LocalHospitalService.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"LocalHospitalService", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Delivers a magic link to login.
  """
  def deliver_magic_link(user, url) do
    deliver(user.email, "Sign in to LocalHospitalService", """

    ==============================

    Hi #{user.email},

    This is your one-time link to login:

    <a href="#{url}" target="_blank"
      style="color: blue; text-decoration: underline">#{url}</a>

    This link will expire in 1 hour.

    If you didn't try to login, please ignore this.

    ==============================
    """)
  end
end
