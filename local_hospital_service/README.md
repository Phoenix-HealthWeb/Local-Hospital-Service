# LocalHospitalService

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

  # ENCOUNTERS

  From localhost:4000/encounters it is possible to view and add an encounter
  Fixed ward not being associated correctly and displayed in each generated encounter
  Encounter at the moment includes ward for local testing purposes
  Add and view wards from localhost:4000/admin/wards

  # TODO

  Check patient's ID before creating encounter. Proceed if ID is in NDB,
  add patient to NDB if not present
