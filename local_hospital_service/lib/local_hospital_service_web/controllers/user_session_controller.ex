defmodule LocalHospitalServiceWeb.UserSessionController do
  use LocalHospitalServiceWeb, :controller

  alias LocalHospitalService.Accounts
  alias LocalHospitalServiceWeb.UserAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  @doc """
  Called when the user makes a POST request to consume the magic link
  """
  def create(conn, %{"_action" => "magic_link", "token" => token} = user_params) do
    Accounts.verify_and_invalidate_magic_link(token)
    |> case do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> UserAuth.log_in_user(user, user_params)

      :error ->
        conn
        |> put_flash(:error, "The link might be expired or invalid")
        |> redirect(to: ~p"/users/log_in")
    end
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid email or password")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/users/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
