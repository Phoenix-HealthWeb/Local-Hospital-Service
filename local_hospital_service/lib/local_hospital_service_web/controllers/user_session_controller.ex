defmodule LocalHospitalServiceWeb.UserSessionController do
  use LocalHospitalServiceWeb, :controller

  alias LocalHospitalService.Accounts
  alias LocalHospitalServiceWeb.UserAuth

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

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
