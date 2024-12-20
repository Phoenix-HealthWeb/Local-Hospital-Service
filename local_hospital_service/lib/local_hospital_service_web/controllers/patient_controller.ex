defmodule NursesWeb.PatientController do
  use NursesWeb, :controller

  alias Nurses.Patients
  alias Nurses.Patients.Patient

  def home(conn, _params) do
    pq = NursesWeb.PriorityQueue.new()
    render(conn, :home, patients: pq)
  end

#per la route /wards
#"General" dovrebbe essere preso da il dottore attuale
  def index(conn, _params) do
    pq1 = NursesWeb.PriorityQueue.new()

    render(conn, :index, patients: pq1)
  end

  #per la route /ward/:id
  #"General" dovrebbe essere preso da il dottore attuale
  #in questo caso con Enum.at sta prendendo il campo ward del primo elemento di una lista
  #di dottori, non di quello corrente
  def indexxxx(conn, %{"id" => id}) do
    pq = NursesWeb.PriorityQueueDoctor.new()

    first_ward = Enum.at(pq, 0).ward
    pq1 = NursesWeb.PriorityQueue.new(id)
    #pq1 = NursesWeb.PriorityQueue.new()

    render(conn, :indexxxx, patients: pq1)
  end


  def new(conn, _params) do
    changeset = Patients.change_patient(%Patient{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"patient" => patient_params}) do
    case Patients.create_patient(patient_params) do
      {:ok, patient} ->
        conn
        |> put_flash(:info, "Patient created successfully.")
        |> redirect(to: ~p"/patients/#{patient}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def get(conn, %{"id" => id}) do
    patient = Patients.get_patient!(id)
    render(conn, :get, patient: patient)
  end

  def edit(conn, %{"id" => id}) do
    patient = Patients.get_patient!(id)
    changeset = Patients.change_patient(patient)
    render(conn, :edit, patient: patient, changeset: changeset)
  end

  def update(conn, %{"id" => id, "patient" => patient_params}) do
    patient = Patients.get_patient!(id)

    case Patients.update_patient(patient, patient_params) do
      {:ok, patient} ->
        conn
        |> put_flash(:info, "Patient updated successfully.")
        |> redirect(to: ~p"/patients/#{patient}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, patient: patient, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    patient = Patients.get_patient!(id)
    {:ok, _patient} = Patients.delete_patient(patient)

    conn
    |> put_flash(:info, "Patient deleted successfully.")
    |> redirect(to: ~p"/patients")
  end
end

defmodule Patient do
  defstruct [:name, :colorcode, :symptom, :ward]
end

defimpl Phoenix.Param, for: Patient do
  def to_param(patient) do
    "#{patient.name}-#{patient.colorcode}-#{patient.symptom}-#{patient.ward}"
  end
end
