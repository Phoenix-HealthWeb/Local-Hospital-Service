defmodule LocalHospitalServiceWeb.DoctorHTML do
  use LocalHospitalServiceWeb, :html

  embed_templates "doctor_html/*"
  embed_templates "patient_html/*"

  @doc """
  Renders a doctor form.
  """
  def render("home.html", assigns) do
    ~H"""
    <h1><strong>Doctor List</strong></h1>
      <%= for doctor <- @doctors do %>
        <li>
        <strong>Doctor:</strong> <%= doctor.name %>, <%= doctor.ward %> <br>
        </li>
      <% end %>

    <ul>
      <%= for patient <- @patients do %>
        <li>
        <strong>Patient:</strong><%= patient.name %>, <%= patient.colorcode %>, <%= patient.symptom %>, <%= patient.ward %> <br>
        </li>
      <% end %>
    </ul>


    """
  end







  def doctor_form(assigns)
end
