defmodule LocalHospitalServiceWeb.PatientLiveTest do
  use LocalHospitalServiceWeb.ConnCase

  import Phoenix.LiveViewTest
  import LocalHospitalService.HospitalFixtures

  @create_attrs %{cf: "some cf", firstname: "some firstname", lastname: "some lastname", date_of_birth: "2025-01-05", gender: "some gender"}
  @update_attrs %{cf: "some updated cf", firstname: "some updated firstname", lastname: "some updated lastname", date_of_birth: "2025-01-06", gender: "some updated gender"}
  @invalid_attrs %{cf: nil, firstname: nil, lastname: nil, date_of_birth: nil, gender: nil}

  defp create_patient(_) do
    patient = patient_fixture()
    %{patient: patient}
  end

  describe "Index" do
    setup [:create_patient]

    test "lists all patients", %{conn: conn, patient: patient} do
      {:ok, _index_live, html} = live(conn, ~p"/patients")

      assert html =~ "Listing Patients"
      assert html =~ patient.cf
    end

    test "saves new patient", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/patients")

      assert index_live |> element("a", "New Patient") |> render_click() =~
               "New Patient"

      assert_patch(index_live, ~p"/patients/new")

      assert index_live
             |> form("#patient-form", patient: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#patient-form", patient: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/patients")

      html = render(index_live)
      assert html =~ "Patient created successfully"
      assert html =~ "some cf"
    end

    test "updates patient in listing", %{conn: conn, patient: patient} do
      {:ok, index_live, _html} = live(conn, ~p"/patients")

      assert index_live |> element("#patients-#{patient.id} a", "Edit") |> render_click() =~
               "Edit Patient"

      assert_patch(index_live, ~p"/patients/#{patient}/edit")

      assert index_live
             |> form("#patient-form", patient: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#patient-form", patient: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/patients")

      html = render(index_live)
      assert html =~ "Patient updated successfully"
      assert html =~ "some updated cf"
    end

    test "deletes patient in listing", %{conn: conn, patient: patient} do
      {:ok, index_live, _html} = live(conn, ~p"/patients")

      assert index_live |> element("#patients-#{patient.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#patients-#{patient.id}")
    end
  end

  describe "Show" do
    setup [:create_patient]

    test "displays patient", %{conn: conn, patient: patient} do
      {:ok, _show_live, html} = live(conn, ~p"/patients/#{patient}")

      assert html =~ "Show Patient"
      assert html =~ patient.cf
    end

    test "updates patient within modal", %{conn: conn, patient: patient} do
      {:ok, show_live, _html} = live(conn, ~p"/patients/#{patient}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Patient"

      assert_patch(show_live, ~p"/patients/#{patient}/show/edit")

      assert show_live
             |> form("#patient-form", patient: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#patient-form", patient: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/patients/#{patient}")

      html = render(show_live)
      assert html =~ "Patient updated successfully"
      assert html =~ "some updated cf"
    end
  end
end
