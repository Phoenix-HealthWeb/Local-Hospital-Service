defmodule LocalHospitalServiceWeb.PatientHTML do
  use LocalHospitalServiceWeb, :html

  embed_templates "patient_html/*"

  @doc """
  Renders a patient form.
  """

  def render("home.html", assigns) do
    ~H"""
    <ul>
      <%= for patient <- @patients do %>
        <li>
        <strong>Patient:</strong> <%= patient.name %>, <%= patient.colorcode %>, <%= patient.symptom %>, <%= patient.ward %> <br>
        </li>
      <% end %>
    </ul>
    """
  end

  def patient_form(assigns)
end
