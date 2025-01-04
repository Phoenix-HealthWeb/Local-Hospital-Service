defmodule LocalHospitalServiceWeb.EncounterLiveTest do
  use LocalHospitalServiceWeb.ConnCase

  import Phoenix.LiveViewTest
  import LocalHospitalService.HospitalFixtures

  @create_attrs %{priority: 42, reason: "some reason", "\\": "some \\", date_time: "2024-12-18T21:10:00", patient: "some patient"}
  @update_attrs %{priority: 43, reason: "some updated reason", "\\": "some updated \\", date_time: "2024-12-19T21:10:00", patient: "some updated patient"}
  @invalid_attrs %{priority: nil, reason: nil, "\\": nil, date_time: nil, patient: nil}

  defp create_encounter(_) do
    encounter = encounter_fixture()
    %{encounter: encounter}
  end

  describe "Index" do
    setup [:create_encounter]

    test "lists all encounters", %{conn: conn, encounter: encounter} do
      {:ok, _index_live, html} = live(conn, ~p"/encounters")

      assert html =~ "Listing Encounters"
      assert html =~ encounter.reason
    end

    test "saves new encounter", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/encounters")

      assert index_live |> element("a", "New Encounter") |> render_click() =~
               "New Encounter"

      assert_patch(index_live, ~p"/encounters/new")

      assert index_live
             |> form("#encounter-form", encounter: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#encounter-form", encounter: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/encounters")

      html = render(index_live)
      assert html =~ "Encounter created successfully"
      assert html =~ "some reason"
    end

    test "updates encounter in listing", %{conn: conn, encounter: encounter} do
      {:ok, index_live, _html} = live(conn, ~p"/encounters")

      assert index_live |> element("#encounters-#{encounter.id} a", "Edit") |> render_click() =~
               "Edit Encounter"

      assert_patch(index_live, ~p"/encounters/#{encounter}/edit")

      assert index_live
             |> form("#encounter-form", encounter: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#encounter-form", encounter: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/encounters")

      html = render(index_live)
      assert html =~ "Encounter updated successfully"
      assert html =~ "some updated reason"
    end

    test "deletes encounter in listing", %{conn: conn, encounter: encounter} do
      {:ok, index_live, _html} = live(conn, ~p"/encounters")

      assert index_live |> element("#encounters-#{encounter.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#encounters-#{encounter.id}")
    end
  end

  describe "Show" do
    setup [:create_encounter]

    test "displays encounter", %{conn: conn, encounter: encounter} do
      {:ok, _show_live, html} = live(conn, ~p"/encounters/#{encounter}")

      assert html =~ "Show Encounter"
      assert html =~ encounter.reason
    end

    test "updates encounter within modal", %{conn: conn, encounter: encounter} do
      {:ok, show_live, _html} = live(conn, ~p"/encounters/#{encounter}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Encounter"

      assert_patch(show_live, ~p"/encounters/#{encounter}/show/edit")

      assert show_live
             |> form("#encounter-form", encounter: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#encounter-form", encounter: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/encounters/#{encounter}")

      html = render(show_live)
      assert html =~ "Encounter updated successfully"
      assert html =~ "some updated reason"
    end
  end
end
