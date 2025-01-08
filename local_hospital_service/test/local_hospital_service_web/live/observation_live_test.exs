defmodule LocalHospitalServiceWeb.ObservationLiveTest do
  use LocalHospitalServiceWeb.ConnCase

  import Phoenix.LiveViewTest
  import LocalHospitalService.ObservationsFixtures

  @create_attrs %{date_time: "2025-01-07T17:05:00Z", ward: "some ward", hospital_id: "some hospital_id"}
  @update_attrs %{date_time: "2025-01-08T17:05:00Z", ward: "some updated ward", hospital_id: "some updated hospital_id"}
  @invalid_attrs %{date_time: nil, ward: nil, hospital_id: nil}

  defp create_observation(_) do
    observation = observation_fixture()
    %{observation: observation}
  end

  describe "Index" do
    setup [:create_observation]

    test "lists all observation", %{conn: conn, observation: observation} do
      {:ok, _index_live, html} = live(conn, ~p"/observation")

      assert html =~ "Listing Observation"
      assert html =~ observation.ward
    end

    test "saves new observation", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/observation")

      assert index_live |> element("a", "New Observation") |> render_click() =~
               "New Observation"

      assert_patch(index_live, ~p"/observation/new")

      assert index_live
             |> form("#observation-form", observation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#observation-form", observation: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/observation")

      html = render(index_live)
      assert html =~ "Observation created successfully"
      assert html =~ "some ward"
    end

    test "updates observation in listing", %{conn: conn, observation: observation} do
      {:ok, index_live, _html} = live(conn, ~p"/observation")

      assert index_live |> element("#observation-#{observation.id} a", "Edit") |> render_click() =~
               "Edit Observation"

      assert_patch(index_live, ~p"/observation/#{observation}/edit")

      assert index_live
             |> form("#observation-form", observation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#observation-form", observation: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/observation")

      html = render(index_live)
      assert html =~ "Observation updated successfully"
      assert html =~ "some updated ward"
    end

    test "deletes observation in listing", %{conn: conn, observation: observation} do
      {:ok, index_live, _html} = live(conn, ~p"/observation")

      assert index_live |> element("#observation-#{observation.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#observation-#{observation.id}")
    end
  end

  describe "Show" do
    setup [:create_observation]

    test "displays observation", %{conn: conn, observation: observation} do
      {:ok, _show_live, html} = live(conn, ~p"/observation/#{observation}")

      assert html =~ "Show Observation"
      assert html =~ observation.ward
    end

    test "updates observation within modal", %{conn: conn, observation: observation} do
      {:ok, show_live, _html} = live(conn, ~p"/observation/#{observation}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Observation"

      assert_patch(show_live, ~p"/observation/#{observation}/show/edit")

      assert show_live
             |> form("#observation-form", observation: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#observation-form", observation: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/observation/#{observation}")

      html = render(show_live)
      assert html =~ "Observation updated successfully"
      assert html =~ "some updated ward"
    end
  end
end
