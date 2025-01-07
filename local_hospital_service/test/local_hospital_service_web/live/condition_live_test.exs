defmodule LocalHospitalServiceWeb.ConditionLiveTest do
  use LocalHospitalServiceWeb.ConnCase

  import Phoenix.LiveViewTest
  import LocalHospitalService.ConditionsFixtures

  @create_attrs %{comment: "some comment", date_time: "2025-01-06T18:16:00Z"}
  @update_attrs %{comment: "some updated comment", date_time: "2025-01-07T18:16:00Z"}
  @invalid_attrs %{comment: nil, date_time: nil}

  defp create_condition(_) do
    condition = condition_fixture()
    %{condition: condition}
  end

  describe "Index" do
    setup [:create_condition]

    test "lists all conditions", %{conn: conn, condition: condition} do
      {:ok, _index_live, html} = live(conn, ~p"/conditions")

      assert html =~ "Listing Conditions"
      assert html =~ condition.comment
    end

    test "saves new condition", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/conditions")

      assert index_live |> element("a", "New Condition") |> render_click() =~
               "New Condition"

      assert_patch(index_live, ~p"/conditions/new")

      assert index_live
             |> form("#condition-form", condition: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#condition-form", condition: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/conditions")

      html = render(index_live)
      assert html =~ "Condition created successfully"
      assert html =~ "some comment"
    end

    test "updates condition in listing", %{conn: conn, condition: condition} do
      {:ok, index_live, _html} = live(conn, ~p"/conditions")

      assert index_live |> element("#conditions-#{condition.id} a", "Edit") |> render_click() =~
               "Edit Condition"

      assert_patch(index_live, ~p"/conditions/#{condition}/edit")

      assert index_live
             |> form("#condition-form", condition: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#condition-form", condition: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/conditions")

      html = render(index_live)
      assert html =~ "Condition updated successfully"
      assert html =~ "some updated comment"
    end

    test "deletes condition in listing", %{conn: conn, condition: condition} do
      {:ok, index_live, _html} = live(conn, ~p"/conditions")

      assert index_live |> element("#conditions-#{condition.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#conditions-#{condition.id}")
    end
  end

  describe "Show" do
    setup [:create_condition]

    test "displays condition", %{conn: conn, condition: condition} do
      {:ok, _show_live, html} = live(conn, ~p"/conditions/#{condition}")

      assert html =~ "Show Condition"
      assert html =~ condition.comment
    end

    test "updates condition within modal", %{conn: conn, condition: condition} do
      {:ok, show_live, _html} = live(conn, ~p"/conditions/#{condition}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Condition"

      assert_patch(show_live, ~p"/conditions/#{condition}/show/edit")

      assert show_live
             |> form("#condition-form", condition: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#condition-form", condition: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/conditions/#{condition}")

      html = render(show_live)
      assert html =~ "Condition updated successfully"
      assert html =~ "some updated comment"
    end
  end
end
