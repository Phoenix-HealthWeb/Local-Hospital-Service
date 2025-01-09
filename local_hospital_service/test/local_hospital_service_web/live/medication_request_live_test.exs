defmodule LocalHospitalServiceWeb.MedicationRequestLiveTest do
  use LocalHospitalServiceWeb.ConnCase

  import Phoenix.LiveViewTest
  import LocalHospitalService.MedicationRequestsFixtures

  @create_attrs %{date_time: "2025-01-07T15:19:00Z", expiration_date: "2025-01-07", medication: "some medication", posology: "some posology"}
  @update_attrs %{date_time: "2025-01-08T15:19:00Z", expiration_date: "2025-01-08", medication: "some updated medication", posology: "some updated posology"}
  @invalid_attrs %{date_time: nil, expiration_date: nil, medication: nil, posology: nil}

  defp create_medication_request(_) do
    medication_request = medication_request_fixture()
    %{medication_request: medication_request}
  end

  describe "Index" do
    setup [:create_medication_request]

    test "lists all medication_request", %{conn: conn, medication_request: medication_request} do
      {:ok, _index_live, html} = live(conn, ~p"/medication_request")

      assert html =~ "Listing Medication request"
      assert html =~ medication_request.medication
    end

    test "saves new medication_request", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/medication_request")

      assert index_live |> element("a", "New Medication request") |> render_click() =~
               "New Medication request"

      assert_patch(index_live, ~p"/medication_request/new")

      assert index_live
             |> form("#medication_request-form", medication_request: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#medication_request-form", medication_request: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/medication_request")

      html = render(index_live)
      assert html =~ "Medication request created successfully"
      assert html =~ "some medication"
    end

    test "updates medication_request in listing", %{conn: conn, medication_request: medication_request} do
      {:ok, index_live, _html} = live(conn, ~p"/medication_request")

      assert index_live |> element("#medication_request-#{medication_request.id} a", "Edit") |> render_click() =~
               "Edit Medication request"

      assert_patch(index_live, ~p"/medication_request/#{medication_request}/edit")

      assert index_live
             |> form("#medication_request-form", medication_request: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#medication_request-form", medication_request: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/medication_request")

      html = render(index_live)
      assert html =~ "Medication request updated successfully"
      assert html =~ "some updated medication"
    end

    test "deletes medication_request in listing", %{conn: conn, medication_request: medication_request} do
      {:ok, index_live, _html} = live(conn, ~p"/medication_request")

      assert index_live |> element("#medication_request-#{medication_request.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#medication_request-#{medication_request.id}")
    end
  end

  describe "Show" do
    setup [:create_medication_request]

    test "displays medication_request", %{conn: conn, medication_request: medication_request} do
      {:ok, _show_live, html} = live(conn, ~p"/medication_request/#{medication_request}")

      assert html =~ "Show Medication request"
      assert html =~ medication_request.medication
    end

    test "updates medication_request within modal", %{conn: conn, medication_request: medication_request} do
      {:ok, show_live, _html} = live(conn, ~p"/medication_request/#{medication_request}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Medication request"

      assert_patch(show_live, ~p"/medication_request/#{medication_request}/show/edit")

      assert show_live
             |> form("#medication_request-form", medication_request: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#medication_request-form", medication_request: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/medication_request/#{medication_request}")

      html = render(show_live)
      assert html =~ "Medication request updated successfully"
      assert html =~ "some updated medication"
    end
  end
end
