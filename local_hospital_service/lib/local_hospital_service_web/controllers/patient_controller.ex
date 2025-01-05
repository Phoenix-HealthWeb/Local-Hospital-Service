defmodule LocalHospitalServiceWeb.PatientController do
  use LocalHospitalServiceWeb, :controller

  def home(conn, _params) do
    pq = LocalHospitalServiceWeb.PriorityQueue.new()
    render(conn, :home, patients: pq)
  end

  #per la ruote /doctors
  def index(conn, _params) do
    pq1 = LocalHospitalServiceWeb.PriorityQueue.new()
    as = LocalHospitalServiceWeb.PriorityQueue.wards_list(pq1)
    as = Enum.map(as, fn ward -> String.trim_trailing(ward) end)
    as = Enum.uniq(as)  # Rimuove i duplicati

    # Ottieni i valori corrispondenti alle chiavi nella mappa
    ward_counts = LocalHospitalServiceWeb.PriorityQueue.wards_counter(pq1)
    # Passa la lista di conteggi e le chiavi alla view
    render(conn, :index, patients: pq1, wards_list: as, list: ward_counts)
  end

  #per la route /ward/:id
  def indexxxx(conn, %{"wardId" => ward_id}) do
    pq1 = LocalHospitalServiceWeb.PriorityQueue.new(ward_id)
    as = LocalHospitalServiceWeb.PriorityQueue.wards_list(pq1)
    as = Enum.map(as, fn ward -> String.trim_trailing(ward) end)
    ward_counts = LocalHospitalServiceWeb.PriorityQueue.wards_counter(pq1)

    render(conn, :indexxxx, patients: pq1, list: as, occurrences: ward_counts)
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

  #QUERY PROVA COLLEGAMENTO DATABASE---------------------------------------------------------------------
  @spec get_by_ward(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def get_by_ward(conn, %{"ward" => ward}) do
    # URL dell'API
    url = "http://localhost:4000/api/patients?ward=#{ward}"

    # Esegui la richiesta GET usando Finch
    case Finch.build(:get, url) |> Finch.request(LocalHospitalServiceWeb.Finch) do
      {:ok, response} ->
        # Se la risposta è positiva, restituisci i dati in JSON
        json(conn, %{message: "Pazienti trovati", data: Jason.decode!(response.body)})

      {:error, reason} ->
        # Se c'è un errore, restituisci un messaggio di errore
        json(conn, %{message: "Errore nella chiamata API", error: reason})
    end
  end
#----------------------------------------------------------------------------------------------------

defimpl Phoenix.Param, for: Patient do
  def to_param(patient) do
    "#{patient.name}-#{patient.colorcode}-#{patient.symptom}-#{patient.ward}"
  end
end
end
