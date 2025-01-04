defmodule LocalHospitalServiceWeb.PageController do
  use LocalHospitalServiceWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def nurses(conn, _params) do
    render(conn, :nurses, layout: {LocalHospitalServiceWeb.Layouts, :app})
  end

  def doctors(conn, _params) do
    render(conn, :doctors, layout: {LocalHospitalServiceWe.Layouts, :app})
  end

  def admins(conn, _params) do
    render(conn, :admins, layout: {LocalHospitalServiceWeb.Layouts, :app})
  end
end
