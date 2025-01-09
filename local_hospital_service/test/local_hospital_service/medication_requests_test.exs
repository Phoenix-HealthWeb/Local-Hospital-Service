defmodule LocalHospitalService.MedicationRequestsTest do
  use LocalHospitalService.DataCase

  alias LocalHospitalService.MedicationRequests

  describe "medication_request" do
    alias LocalHospitalService.MedicationRequests.MedicationRequest

    import LocalHospitalService.MedicationRequestsFixtures

    @invalid_attrs %{date_time: nil, expiration_date: nil, medication: nil, posology: nil}

    test "list_medication_request/0 returns all medication_request" do
      medication_request = medication_request_fixture()
      assert MedicationRequests.list_medication_request() == [medication_request]
    end

    test "get_medication_request!/1 returns the medication_request with given id" do
      medication_request = medication_request_fixture()
      assert MedicationRequests.get_medication_request!(medication_request.id) == medication_request
    end

    test "create_medication_request/1 with valid data creates a medication_request" do
      valid_attrs = %{date_time: ~U[2025-01-07 15:19:00Z], expiration_date: ~D[2025-01-07], medication: "some medication", posology: "some posology"}

      assert {:ok, %MedicationRequest{} = medication_request} = MedicationRequests.create_medication_request(valid_attrs)
      assert medication_request.date_time == ~U[2025-01-07 15:19:00Z]
      assert medication_request.expiration_date == ~D[2025-01-07]
      assert medication_request.medication == "some medication"
      assert medication_request.posology == "some posology"
    end

    test "create_medication_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = MedicationRequests.create_medication_request(@invalid_attrs)
    end

    test "update_medication_request/2 with valid data updates the medication_request" do
      medication_request = medication_request_fixture()
      update_attrs = %{date_time: ~U[2025-01-08 15:19:00Z], expiration_date: ~D[2025-01-08], medication: "some updated medication", posology: "some updated posology"}

      assert {:ok, %MedicationRequest{} = medication_request} = MedicationRequests.update_medication_request(medication_request, update_attrs)
      assert medication_request.date_time == ~U[2025-01-08 15:19:00Z]
      assert medication_request.expiration_date == ~D[2025-01-08]
      assert medication_request.medication == "some updated medication"
      assert medication_request.posology == "some updated posology"
    end

    test "update_medication_request/2 with invalid data returns error changeset" do
      medication_request = medication_request_fixture()
      assert {:error, %Ecto.Changeset{}} = MedicationRequests.update_medication_request(medication_request, @invalid_attrs)
      assert medication_request == MedicationRequests.get_medication_request!(medication_request.id)
    end

    test "delete_medication_request/1 deletes the medication_request" do
      medication_request = medication_request_fixture()
      assert {:ok, %MedicationRequest{}} = MedicationRequests.delete_medication_request(medication_request)
      assert_raise Ecto.NoResultsError, fn -> MedicationRequests.get_medication_request!(medication_request.id) end
    end

    test "change_medication_request/1 returns a medication_request changeset" do
      medication_request = medication_request_fixture()
      assert %Ecto.Changeset{} = MedicationRequests.change_medication_request(medication_request)
    end
  end
end
