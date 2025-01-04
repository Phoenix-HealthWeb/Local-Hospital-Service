defmodule LocalHospitalServiceWeb.WardLiveTest do
  use LocalHospitalServiceWeb.ConnCase

  import Phoenix.LiveViewTest
  import LocalHospitalService.HospitalFixtures

  @create_attrs %{name: "some name", "\\": "some \\", "\\description": "some \\description"}
  @update_attrs %{name: "some updated name", "\\": "some updated \\", "\\description": "some updated \\description"}
  @invalid_attrs %{name: nil, "\\": nil, "\\description": nil}

  defp create_ward(_) do
    ward = ward_fixture()
    %{ward: ward}
  end

  describe "Index" do
    setup [:create_ward]

    test "lists all wards", %{conn: conn, ward: ward} do
      {:ok, _index_live, html} = live(conn, ~p"/wards")

      assert html =~ "Listing Wards"
      assert html =~ ward.name
    end

    test "saves new ward", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/wards")

      assert index_live |> element("a", "New Ward") |> render_click() =~
               "New Ward"

      assert_patch(index_live, ~p"/wards/new")

      assert index_live
             |> form("#ward-form", ward: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#ward-form", ward: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/wards")

      html = render(index_live)
      assert html =~ "Ward created successfully"
      assert html =~ "some name"
    end

    test "updates ward in listing", %{conn: conn, ward: ward} do
      {:ok, index_live, _html} = live(conn, ~p"/wards")

      assert index_live |> element("#wards-#{ward.id} a", "Edit") |> render_click() =~
               "Edit Ward"

      assert_patch(index_live, ~p"/wards/#{ward}/edit")

      assert index_live
             |> form("#ward-form", ward: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#ward-form", ward: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/wards")

      html = render(index_live)
      assert html =~ "Ward updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes ward in listing", %{conn: conn, ward: ward} do
      {:ok, index_live, _html} = live(conn, ~p"/wards")

      assert index_live |> element("#wards-#{ward.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#wards-#{ward.id}")
    end
  end

  describe "Show" do
    setup [:create_ward]

    test "displays ward", %{conn: conn, ward: ward} do
      {:ok, _show_live, html} = live(conn, ~p"/wards/#{ward}")

      assert html =~ "Show Ward"
      assert html =~ ward.name
    end

    test "updates ward within modal", %{conn: conn, ward: ward} do
      {:ok, show_live, _html} = live(conn, ~p"/wards/#{ward}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Ward"

      assert_patch(show_live, ~p"/wards/#{ward}/show/edit")

      assert show_live
             |> form("#ward-form", ward: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#ward-form", ward: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/wards/#{ward}")

      html = render(show_live)
      assert html =~ "Ward updated successfully"
      assert html =~ "some updated name"
    end
  end
end
