defmodule LocalHospitalService.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias LocalHospitalService.Repo

  alias LocalHospitalService.Accounts.{UserToken, UserNotifier}

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    # TODO:
    LocalHospitalService.Api.Practitioner.get_by_email(email)
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Magic link

  @doc """
  Generates and sends magic link for the given email.

  If the email does not correspond to any user, if fails silently.

  Returns the generated token, or nil otherwise
  """
  def generate_magic_link(email, magic_link_url_fun) when is_function(magic_link_url_fun, 1) do
    if user = get_user_by_email(email) do
      {email_token, token} = UserToken.build_email_token(user, "magic_link")
      Repo.insert!(token)

      UserNotifier.deliver_magic_link(
        user,
        magic_link_url_fun.(email_token)
      )

      email_token
    else
      nil
    end
  end

  @doc """
  Verifies the magic link token and returns the user if valid.
  Additionally, the token is invalidated.
  """
  def verify_and_invalidate_magic_link(token) do
    with {:ok, query} <- UserToken.verify_email_token_query_full_token(token, "magic_link") do
      try do
        # If ok, the transaction will return {:ok, return_value}
        Repo.transaction(fn ->
          # If the token does not exist, Repo.one/1 will return nil, so the match will fail
          # and transaction will be rolled back automatically
          %UserToken{} = token_row = Repo.one(query)
          Repo.delete(token_row)

          token_row.user
        end)
      rescue
        _ -> :error
      end
    else
      _ -> :error
    end
  end
end
