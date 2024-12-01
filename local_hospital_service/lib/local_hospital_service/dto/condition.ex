defmodule LocalHospitalService.Dto.Condition do
  @moduledoc """
  Represents a condition annotated on the patient.
  """

  @enforce_keys [:practitioner, :patient, :dateTime, :comment]
  defstruct [
    # Unique identifier. Optional if the condition has not yet been persisted
    :id,
    # Id of the pratictioner (medical staff) who annotated the condition
    :practitioner,
    # Id of the patient whose condition is being recorded
    :patient,
    # ISO string representing the date and time when the condition was annotated
    :dateTime,
    # Comment indicating the condition
    :comment
  ]
end
