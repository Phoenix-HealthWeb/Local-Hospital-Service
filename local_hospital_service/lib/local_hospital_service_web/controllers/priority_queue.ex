defmodule LocalHospitalServiceWeb.PriorityQueue do

  def new(ward) do
    patients = PatientParser.parse_file("pazienti.txt")
    patients |> PatientSorter.enqueue(ward)
  end

  def new() do
    patients = PatientParser.parse_file("pazienti.txt")
    patients |> PatientSorter.enqueue()
  end

  def wards_list(quack) do
    # Usa un accumulatore per raccogliere i ward unici
    Enum.reduce(quack, [], fn patient, wards_list ->
      # Verifica se il ward non è già presente nella lista
      if patient.ward not in wards_list do
        [patient.ward | wards_list]  # Aggiungi il ward alla lista
      else
        wards_list  # Non aggiungere il ward se è già presente
      end
    end)
    |> Enum.reverse()  # Inverte la lista per mantenere l'ordine di apparizione originale
  end

  def wards_counter(quack) do
    # Estrae le ward dalla lista dei pazienti, rimuove eventuali spazi finali, e rimuove i duplicati
    wards = quack
            |> Enum.map(fn patient -> String.trim_trailing(patient.ward) end)  # Rimuove gli spazi finali
            |> Enum.uniq()  # Rimuove i duplicati

    # Conta le occorrenze di ogni ward nella lista dei pazienti
    Enum.map(wards, fn ward ->
      quack
      |> Enum.count(fn patient -> String.trim_trailing(patient.ward) == ward end)  # Confronta senza spazi finali
    end)
  end







  # ... altri metodi come dequeue, peek, ecc.
end

defmodule Patient do
  defstruct [:name, :colorcode, :symptom, :ward]
end

defmodule PatientParser do
  def parse_file(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_patient/1)
  end

  def parse_patient(line) do
    # Dividi i campi con un separatore più permissivo
    case String.split(line, ~r/\s*,\s*/) do
      [name, colorcode, symptom, ward] ->
        %Patient{
          name: String.trim(name),
          colorcode: String.trim(colorcode),
          symptom: String.trim(symptom),
          ward: String.trim(ward)
        }

      _ ->
        raise ArgumentError, "Invalid line format: #{line}"
    end
  end

end

defmodule PatientSorter do
  def enqueue(patients,ward) do
    unless is_list(patients) and Enum.all?(patients, fn p -> is_struct(p, Patient) end) do
      raise ArgumentError, "Expected a list of Patient structs"
    end


    first_two_patients = Enum.take(patients, 5)
  new_enum = Enum.filter(first_two_patients, fn p -> String.contains?(p.ward, ward) end)


    Enum.sort(new_enum, fn patient1, patient2 ->
      color_priority(patient1.colorcode) > color_priority(patient2.colorcode)
    end)
  end


  def enqueue(patients) do
    unless is_list(patients) and Enum.all?(patients, fn p -> is_struct(p, Patient) end) do
      raise ArgumentError, "Expected a list of Patient structs"
    end

    Enum.sort(patients, fn patient1, patient2 ->
      color_priority(patient1.colorcode) > color_priority(patient2.colorcode)
    end)
  end



  defp color_priority("rosso"), do: 4
  defp color_priority("arancione"), do: 3
  defp color_priority("verde"), do: 2
  defp color_priority("bianco"), do: 1
end


defmodule MyEnum do
  def remove_if_not_contains(enum, substring) do
    case Enum.take(enum, 1) do
      [first_element] ->
        if String.contains?(first_element, substring) do
          [first_element | Enum.drop(enum, 1)]
        else
          Enum.drop(enum, 1)
        end
      _ ->
        []
    end
  end
end
