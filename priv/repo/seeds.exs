# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     RemoteExercise.Repo.insert!(%RemoteExercise.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias RemoteExercise.Accounts.User
alias RemoteExercise.Repo

now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
placeholders = %{now: now}

1..20
|> Stream.map(fn _ -> for _ <- 1..50_000, do: %{points: 0, inserted_at: {:placeholder, :now}, updated_at: {:placeholder, :now}} end)
|> Stream.map(fn entries -> Repo.insert_all(User, entries, placeholders: placeholders) end)
|> Stream.run()
