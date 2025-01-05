defmodule LocalHospitalServiceWeb.CfVerificationHTML do
  use LocalHospitalServiceWeb, :html

  # Tutti i file .heex nella directory "cf_verification_html/*" verranno
  # inglobati e trasformati in funzioni, in base al nome del file.
  embed_templates "cf_verification_html/*"
end
