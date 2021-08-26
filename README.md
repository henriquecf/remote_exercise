# RemoteExercise

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## RemoteExercise.UserPoints

The main logic of this app lives in the `UserPoints` GenServer. It is started together of the whole app and runs an update on all Users points every 1 minute, and sets a `max_number` that will define the users to be queried.

It also allows to query for 2 users that have `points > max_number` and update the timestamp of the last query. This function is used in the root endpoint to show the 2 users retrieved and the timestamp of the previous call.

## Seeds

We use the `priv/repo/seeds.exs` to seed 1_000_000 users into the database. We divide into 20 different `insert_all` calls, because Postgres only allows 65535 paramaters at a time.

We also stream calls to allow parallel execution.
