defmodule LocalHospitalService.Dto.Observation do
  @moduledoc """
  Represents an observation made by a practitioner on a patient.
  """

  @enforce_keys [:practitioner, :patient, :ward, :dateTime, :result]
  defstruct [
    # Unique identifier. Optional if the observation has not yet been persisted
    :id,
    # Id of the pratictioner (medical staff) who made the observation
    :practitioner,
    # Id of the patient whose observation is being recorded
    :patient,
    # Name of the ward where the observation was made
    :ward,
    # ISO string representing the date and time of the observation
    :dateTime,
    # Comment indicating the result of the observation
    :result
  ]
end
