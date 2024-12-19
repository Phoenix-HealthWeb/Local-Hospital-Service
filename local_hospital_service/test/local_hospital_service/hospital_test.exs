defmodule LocalHospitalService.HospitalTest do
  use LocalHospitalService.DataCase

  alias LocalHospitalService.Hospital

  describe "encounters" do
    alias LocalHospitalService.Hospital.Encounter

    import LocalHospitalService.HospitalFixtures

    @invalid_attrs %{priority: nil, reason: nil, "\\": nil, date_time: nil, patient: nil}

    test "list_encounters/0 returns all encounters" do
      encounter = encounter_fixture()
      assert Hospital.list_encounters() == [encounter]
    end

    test "get_encounter!/1 returns the encounter with given id" do
      encounter = encounter_fixture()
      assert Hospital.get_encounter!(encounter.id) == encounter
    end

    test "create_encounter/1 with valid data creates a encounter" do
      valid_attrs = %{priority: 42, reason: "some reason", "\\": "some \\", date_time: ~N[2024-12-18 21:10:00], patient: "some patient"}

      assert {:ok, %Encounter{} = encounter} = Hospital.create_encounter(valid_attrs)
      assert encounter.priority == 42
      assert encounter.reason == "some reason"
      assert encounter.\ == "some \\"
      assert encounter.date_time == ~N[2024-12-18 21:10:00]
      assert encounter.patient == "some patient"
    end

    test "create_encounter/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hospital.create_encounter(@invalid_attrs)
    end

    test "update_encounter/2 with valid data updates the encounter" do
      encounter = encounter_fixture()
      update_attrs = %{priority: 43, reason: "some updated reason", "\\": "some updated \\", date_time: ~N[2024-12-19 21:10:00], patient: "some updated patient"}

      assert {:ok, %Encounter{} = encounter} = Hospital.update_encounter(encounter, update_attrs)
      assert encounter.priority == 43
      assert encounter.reason == "some updated reason"
      assert encounter.\ == "some updated \\"
      assert encounter.date_time == ~N[2024-12-19 21:10:00]
      assert encounter.patient == "some updated patient"
    end

    test "update_encounter/2 with invalid data returns error changeset" do
      encounter = encounter_fixture()
      assert {:error, %Ecto.Changeset{}} = Hospital.update_encounter(encounter, @invalid_attrs)
      assert encounter == Hospital.get_encounter!(encounter.id)
    end

    test "delete_encounter/1 deletes the encounter" do
      encounter = encounter_fixture()
      assert {:ok, %Encounter{}} = Hospital.delete_encounter(encounter)
      assert_raise Ecto.NoResultsError, fn -> Hospital.get_encounter!(encounter.id) end
    end

    test "change_encounter/1 returns a encounter changeset" do
      encounter = encounter_fixture()
      assert %Ecto.Changeset{} = Hospital.change_encounter(encounter)
    end
  end
end
