defmodule LocalHospitalService.Dto.MedicationRequest do
  @moduledoc """
  Represents a medication prescrived to a patient.
  """

  @enforce_keys [:practitioner, :patient, :dateTime, :medication, :posology]
  defstruct [
    # Unique identifier. Optional if the medication req has not yet been persisted
    :id,
    # Id of the pratictioner (medical staff) who requested the medication
    :practitioner,
    # Id of the patient who the medication is being prescribed to
    :patient,
    # ISO string representing the date and time when the medication was requested
    :dateTime,
    # ISO string representing the date and time of the medication expiration.
    # If the medication does not expire, this field should be nil
    :expirationDate,
    # Name of the medicine
    :medication,
    # Comment indicating how and when the medication should be taken
    :posology
  ]
end
