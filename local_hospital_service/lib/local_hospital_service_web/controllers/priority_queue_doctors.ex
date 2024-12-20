defmodule NursesWeb.PriorityQueueDoctor do

  def new() do
    doctors = DoctorParser.parse_file("dottori.txt")

    doctors |> DoctorSorter.enqueue()
  end

  @spec enqueue(any()) :: list()
  def enqueue(doctors) do
    doctors = DoctorSorter.enqueue(doctors)
  end

  # ... altri metodi come dequeue, peek, ecc.
end

defmodule Doctor do
  defstruct [:name, :ward]
end

defmodule DoctorParser do
  def parse_file(filename) do
    File.read!(filename)
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_doctor/1)
  end

  defp parse_doctor(line) do
    [name, ward] = String.split(line, ", ", trim: true)
    %Doctor{name: name, ward: ward}
  end
end

defmodule DoctorSorter do
  def enqueue(doctors) do
    unless is_list(doctors) and Enum.all?(doctors, fn p -> is_struct(p, Doctor) end) do
      raise ArgumentError, "Expected a list of Patient structs"
    end

    Enum.sort(doctors, fn doctor1, doctor2 ->
      doctor1.name > doctor2.name
    end)
  end
end
