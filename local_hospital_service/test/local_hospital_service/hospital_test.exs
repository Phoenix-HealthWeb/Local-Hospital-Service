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
end
