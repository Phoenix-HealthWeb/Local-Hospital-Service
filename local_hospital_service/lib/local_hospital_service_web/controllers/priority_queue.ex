defmodule NursesWeb.PriorityQueue do

  def new(ward) do
    patients = PatientParser.parse_file("pazienti.txt")
    patients |> PatientSorter.enqueue(ward)

  end

  def new() do
    patients = PatientParser.parse_file("pazienti.txt")
    patients |> PatientSorter.enqueue()

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

  defp parse_patient(line) do
    [name, colorcode, symptom, ward] = String.split(line, ", ", trim: true)
    %Patient{name: name, colorcode: colorcode, symptom: symptom, ward: ward}
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
