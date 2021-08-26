defmodule RemoteExerciseWeb.UserView do
  use RemoteExerciseWeb, :view
  alias RemoteExerciseWeb.UserView

  def render("index.json", %{users: users, timestamp: timestamp}) do
    %{
      users: render_many(users, UserView, "user.json"),
      timestamp: timestamp
    }
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      points: user.points
    }
  end
end
