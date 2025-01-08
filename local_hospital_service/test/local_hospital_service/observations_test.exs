defmodule LocalHospitalService.ObservationsTest do
  use LocalHospitalService.DataCase

  alias LocalHospitalService.Observations

  describe "observation" do
    alias LocalHospitalService.Observations.Observation

    import LocalHospitalService.ObservationsFixtures

    @invalid_attrs %{date_time: nil, ward: nil, hospital_id: nil}

    test "list_observation/0 returns all observation" do
      observation = observation_fixture()
      assert Observations.list_observation() == [observation]
    end

    test "get_observation!/1 returns the observation with given id" do
      observation = observation_fixture()
      assert Observations.get_observation!(observation.id) == observation
    end

    test "create_observation/1 with valid data creates a observation" do
      valid_attrs = %{date_time: ~U[2025-01-07 17:05:00Z], ward: "some ward", hospital_id: "some hospital_id"}

      assert {:ok, %Observation{} = observation} = Observations.create_observation(valid_attrs)
      assert observation.date_time == ~U[2025-01-07 17:05:00Z]
      assert observation.ward == "some ward"
      assert observation.hospital_id == "some hospital_id"
    end

    test "create_observation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Observations.create_observation(@invalid_attrs)
    end

    test "update_observation/2 with valid data updates the observation" do
      observation = observation_fixture()
      update_attrs = %{date_time: ~U[2025-01-08 17:05:00Z], ward: "some updated ward", hospital_id: "some updated hospital_id"}

      assert {:ok, %Observation{} = observation} = Observations.update_observation(observation, update_attrs)
      assert observation.date_time == ~U[2025-01-08 17:05:00Z]
      assert observation.ward == "some updated ward"
      assert observation.hospital_id == "some updated hospital_id"
    end

    test "update_observation/2 with invalid data returns error changeset" do
      observation = observation_fixture()
      assert {:error, %Ecto.Changeset{}} = Observations.update_observation(observation, @invalid_attrs)
      assert observation == Observations.get_observation!(observation.id)
    end

    test "delete_observation/1 deletes the observation" do
      observation = observation_fixture()
      assert {:ok, %Observation{}} = Observations.delete_observation(observation)
      assert_raise Ecto.NoResultsError, fn -> Observations.get_observation!(observation.id) end
    end

    test "change_observation/1 returns a observation changeset" do
      observation = observation_fixture()
      assert %Ecto.Changeset{} = Observations.change_observation(observation)
    end
  end
end
