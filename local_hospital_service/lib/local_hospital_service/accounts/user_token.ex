defmodule LocalHospitalService.Accounts.UserToken do
  use Ecto.Schema
  import Ecto.Query
  alias LocalHospitalService.Accounts.UserToken

  @hash_algorithm :sha256
  @rand_size 32

  @session_validity_in_minutes 60 * 24 * 60

  # Expiration time for magic link tokens
  @magic_link_validity_in_minutes 60

  schema "users_tokens" do
    field :token, :binary
    field :context, :string
    field :sent_to, :string
    # TODO: Should be :id maybe just for mock
    field :user_id, :id
    embeds_one :user, LocalHospitalService.Accounts.User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.

  The reason why we store session tokens in the database, even
  though Phoenix already provides a session cookie, is because
  Phoenix' default session cookies are not persisted, they are
  simply signed and potentially encrypted. This means they are
  valid indefinitely, unless you change the signing/encryption
  salt.

  Therefore, storing them allows individual user
  sessions to be expired. The token system can also be extended
  to store additional data, such as the device used for logging in.
  You could then use this information to display all valid sessions
  and devices in the UI and allow users to explicitly expire any
  session they deem invalid.
  """
  def build_session_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %UserToken{token: token, context: "session", user_id: user.id, user: user}}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The token is valid if it matches the value in the database and it has
  not expired (after @session_validity_in_minutes).
  """
  def verify_session_token_query(token) do
    query =
      from token in by_token_and_context_query(token, "session"),
        where: token.inserted_at > ago(@session_validity_in_minutes, "minute"),
        select: token.user

    {:ok, query}
  end

  @doc """
  Builds a token and its hash to be delivered to the user's email.

  The non-hashed token is sent to the user email while the
  hashed part is stored in the database. The original token cannot be reconstructed,
  which means anyone with read-only access to the database cannot directly use
  the token in the application to gain access. Furthermore, if the user changes
  their email in the system, the tokens sent to the previous email are no longer
  valid.

  Users can easily adapt the existing code to provide other types of delivery methods,
  for example, by phone numbers.
  """
  def build_email_token(user, "magic_link" = context) do
    build_hashed_token(user, context, user.email)
  end

  defp build_hashed_token(user, context, sent_to) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %UserToken{
       token: hashed_token,
       context: context,
       sent_to: sent_to,
       user_id: user.id,
       user: user
     }}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.
  """
  def verify_email_token_query(token, "magic_link" = context) do
    # Use the full token query to get the user
    case verify_email_token_query_full_token_inner(token, context) do
      {:ok, query} -> {:ok, from(token in query, select: token.user)}
      :error -> :error
    end
  end

  @doc """
  Like the above verify_email_token_query/2, but returns the full token row instead
  """
  def verify_email_token_query_full_token(token, "magic_link" = context) do
    case verify_email_token_query_full_token_inner(token, context) do
      {:ok, query} -> {:ok, from(token in query, select: token)}
      :error -> :error
    end
  end

  defp verify_email_token_query_full_token_inner(token, "magic_link" = context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        minutes = minutes_for_context(context)

        query =
          from token in by_token_and_context_query(hashed_token, context),
            where: token.inserted_at > ago(^minutes, "minute")

        {:ok, query}

      :error ->
        :error
    end
  end

  defp minutes_for_context("magic_link"), do: @magic_link_validity_in_minutes

  @doc """
  Returns the token struct for the given token value and context.
  """
  def by_token_and_context_query(token, context) do
    from UserToken, where: [token: ^token, context: ^context]
  end
end
