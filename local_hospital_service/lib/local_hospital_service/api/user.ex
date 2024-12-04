defmodule LocalHospitalService.Api.User do
  use Agent

  def start_link(_init_args) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get_by_email(email) do
    Agent.get(__MODULE__, fn state -> Map.get(state, email) end)
  end

  def get_by_id!(id) do
    case Agent.get(__MODULE__, fn state -> Map.get(state, id) end) do
      nil -> raise Ecto.NoResultsError
      user -> user
    end
  end

  def create(%Ecto.Changeset{} = changeset) do
    # Set the id field of the changeset to a random number between 0 and 10000
    ch2 = Ecto.Changeset.change(changeset, id: :rand.uniform(10000))

    user_to_create = Ecto.Changeset.apply_changes(ch2)

    Agent.update(__MODULE__, fn state -> Map.put(state, user_to_create.id, user_to_create) end)

    {:ok, user_to_create}
  end

  def update(%Ecto.Changeset{} = changeset) do
    updated_user = Ecto.Changeset.apply_changes(changeset);

    Agent.update(__MODULE__, fn state -> Map.put(state, updated_user.id, updated_user) end)

    {:ok, updated_user}
  end
end
