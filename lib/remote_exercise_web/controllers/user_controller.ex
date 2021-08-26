defmodule RemoteExerciseWeb.UserController do
  use RemoteExerciseWeb, :controller

  def index(conn, _params) do
    %{users: users, timestamp: timestamp} = GenServer.call(RemoteExercise.UserPoints, :query)

    conn
    |> assign(:users, users)
    |> assign(:timestamp, timestamp)
    |> render("index.json")
  end
end
