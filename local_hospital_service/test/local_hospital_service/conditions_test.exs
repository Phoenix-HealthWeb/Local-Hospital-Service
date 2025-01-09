defmodule LocalHospitalService.ConditionsTest do
  use LocalHospitalService.DataCase

  alias LocalHospitalService.Conditions

  describe "conditions" do
    alias LocalHospitalService.Conditions.Condition

    import LocalHospitalService.ConditionsFixtures

    @invalid_attrs %{comment: nil, date_time: nil}

    test "list_conditions/0 returns all conditions" do
      condition = condition_fixture()
      assert Conditions.list_conditions() == [condition]
    end

    test "get_condition!/1 returns the condition with given id" do
      condition = condition_fixture()
      assert Conditions.get_condition!(condition.id) == condition
    end

    test "create_condition/1 with valid data creates a condition" do
      valid_attrs = %{comment: "some comment", date_time: ~U[2025-01-06 18:16:00Z]}

      assert {:ok, %Condition{} = condition} = Conditions.create_condition(valid_attrs)
      assert condition.comment == "some comment"
      assert condition.date_time == ~U[2025-01-06 18:16:00Z]
    end

    test "create_condition/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Conditions.create_condition(@invalid_attrs)
    end

    test "update_condition/2 with valid data updates the condition" do
      condition = condition_fixture()
      update_attrs = %{comment: "some updated comment", date_time: ~U[2025-01-07 18:16:00Z]}

      assert {:ok, %Condition{} = condition} = Conditions.update_condition(condition, update_attrs)
      assert condition.comment == "some updated comment"
      assert condition.date_time == ~U[2025-01-07 18:16:00Z]
    end

    test "update_condition/2 with invalid data returns error changeset" do
      condition = condition_fixture()
      assert {:error, %Ecto.Changeset{}} = Conditions.update_condition(condition, @invalid_attrs)
      assert condition == Conditions.get_condition!(condition.id)
    end

    test "delete_condition/1 deletes the condition" do
      condition = condition_fixture()
      assert {:ok, %Condition{}} = Conditions.delete_condition(condition)
      assert_raise Ecto.NoResultsError, fn -> Conditions.get_condition!(condition.id) end
    end

    test "change_condition/1 returns a condition changeset" do
      condition = condition_fixture()
      assert %Ecto.Changeset{} = Conditions.change_condition(condition)
    end
  end
end
