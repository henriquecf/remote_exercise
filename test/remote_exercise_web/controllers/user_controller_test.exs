defmodule RemoteExerciseWeb.UserControllerTest do
  use RemoteExerciseWeb.ConnCase

  alias RemoteExercise.Repo
  alias RemoteExercise.Accounts.User

  setup %{conn: conn} do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    entries = for _ <- 1..3, do: %{points: 100, inserted_at: now, updated_at: now}
    Repo.insert_all(User, entries)

    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists up to 2 users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))

      response = json_response(conn, 200)
      assert Enum.count(response["users"]) <= 2
    end
  end
end
