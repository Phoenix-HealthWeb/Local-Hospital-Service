defmodule LocalHospitalService.HospitalTest do
  use LocalHospitalService.DataCase

  alias LocalHospitalService.Hospital

  describe "wards" do
    alias LocalHospitalService.Hospital.Ward

    import LocalHospitalService.HospitalFixtures

    @invalid_attrs %{name: nil, "\\": nil, "\\description": nil}

    test "list_wards/0 returns all wards" do
      ward = ward_fixture()
      assert Hospital.list_wards() == [ward]
    end

    test "get_ward!/1 returns the ward with given id" do
      ward = ward_fixture()
      assert Hospital.get_ward!(ward.id) == ward
    end

    test "create_ward/1 with valid data creates a ward" do
      valid_attrs = %{name: "some name", "\\": "some \\", "\\description": "some \\description"}

      assert {:ok, %Ward{} = ward} = Hospital.create_ward(valid_attrs)
      assert ward.name == "some name"
      assert ward.\ == "some \\"
      assert ward.\description == "some \\description"
    end

    test "create_ward/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hospital.create_ward(@invalid_attrs)
    end

    test "update_ward/2 with valid data updates the ward" do
      ward = ward_fixture()
      update_attrs = %{name: "some updated name", "\\": "some updated \\", "\\description": "some updated \\description"}

      assert {:ok, %Ward{} = ward} = Hospital.update_ward(ward, update_attrs)
      assert ward.name == "some updated name"
      assert ward.\ == "some updated \\"
      assert ward.\description == "some updated \\description"
    end

    test "update_ward/2 with invalid data returns error changeset" do
      ward = ward_fixture()
      assert {:error, %Ecto.Changeset{}} = Hospital.update_ward(ward, @invalid_attrs)
      assert ward == Hospital.get_ward!(ward.id)
    end

    test "delete_ward/1 deletes the ward" do
      ward = ward_fixture()
      assert {:ok, %Ward{}} = Hospital.delete_ward(ward)
      assert_raise Ecto.NoResultsError, fn -> Hospital.get_ward!(ward.id) end
    end

    test "change_ward/1 returns a ward changeset" do
      ward = ward_fixture()
      assert %Ecto.Changeset{} = Hospital.change_ward(ward)
    end
  end
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

  describe "patients" do
    alias LocalHospitalService.Hospital.Patient

    import LocalHospitalService.HospitalFixtures

    @invalid_attrs %{cf: nil, firstname: nil, lastname: nil, date_of_birth: nil, gender: nil}

    test "list_patients/0 returns all patients" do
      patient = patient_fixture()
      assert Hospital.list_patients() == [patient]
    end

    test "get_patient!/1 returns the patient with given id" do
      patient = patient_fixture()
      assert Hospital.get_patient!(patient.id) == patient
    end

    test "create_patient/1 with valid data creates a patient" do
      valid_attrs = %{cf: "some cf", firstname: "some firstname", lastname: "some lastname", date_of_birth: ~D[2025-01-05], gender: "some gender"}

      assert {:ok, %Patient{} = patient} = Hospital.create_patient(valid_attrs)
      assert patient.cf == "some cf"
      assert patient.firstname == "some firstname"
      assert patient.lastname == "some lastname"
      assert patient.date_of_birth == ~D[2025-01-05]
      assert patient.gender == "some gender"
    end

    test "create_patient/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hospital.create_patient(@invalid_attrs)
    end

    test "update_patient/2 with valid data updates the patient" do
      patient = patient_fixture()
      update_attrs = %{cf: "some updated cf", firstname: "some updated firstname", lastname: "some updated lastname", date_of_birth: ~D[2025-01-06], gender: "some updated gender"}

      assert {:ok, %Patient{} = patient} = Hospital.update_patient(patient, update_attrs)
      assert patient.cf == "some updated cf"
      assert patient.firstname == "some updated firstname"
      assert patient.lastname == "some updated lastname"
      assert patient.date_of_birth == ~D[2025-01-06]
      assert patient.gender == "some updated gender"
    end

    test "update_patient/2 with invalid data returns error changeset" do
      patient = patient_fixture()
      assert {:error, %Ecto.Changeset{}} = Hospital.update_patient(patient, @invalid_attrs)
      assert patient == Hospital.get_patient!(patient.id)
    end

    test "delete_patient/1 deletes the patient" do
      patient = patient_fixture()
      assert {:ok, %Patient{}} = Hospital.delete_patient(patient)
      assert_raise Ecto.NoResultsError, fn -> Hospital.get_patient!(patient.id) end
    end

    test "change_patient/1 returns a patient changeset" do
      patient = patient_fixture()
      assert %Ecto.Changeset{} = Hospital.change_patient(patient)
    end
  end
end
