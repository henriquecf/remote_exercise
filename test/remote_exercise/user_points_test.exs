defmodule RemoteExercise.UserPointsTest do
  use RemoteExerciseWeb.ConnCase

  alias RemoteExercise.UserPoints
  alias RemoteExercise.Repo
  alias RemoteExercise.Accounts.User

  describe "init/1" do
    test "sets max_number from 0..100" do
      assert {:ok, %{max_number: max}} = UserPoints.init([])
      assert max in 0..100
    end

    test "sets timestamp as nil" do
      assert {:ok, %{timestamp: nil}} = UserPoints.init([])
    end

    test "sends update_users_points_and_max_number message" do
      UserPoints.init(timeout: 10)
      assert_receive :update_users_points_and_max_number
    end
  end

  describe "handle_call/3 query" do
    setup do
      ten_seconds_ago = NaiveDateTime.utc_now() |> NaiveDateTime.add(-10) |> NaiveDateTime.truncate(:second)
      default_args = %{timestamp: ten_seconds_ago, max_number: 10}
      {:ok, default_args: default_args}
    end

    test "replies with users and timestamp", %{default_args: default_args} do
      assert {:reply, %{users: [], timestamp: timestamp}, _} = UserPoints.handle_call(:query, nil, default_args)

      assert timestamp == default_args.timestamp
    end

    test "updates the timestamp on state", %{default_args: default_args} do
      assert {:reply, _, %{timestamp: timestamp}} = UserPoints.handle_call(:query, nil, default_args)

      assert timestamp != default_args.timestamp
    end

    test "queries at most 2 users with more than 10 points", %{default_args: default_args} do
      users = Enum.map([15, 10, 11, 50], fn points ->
        changeset = User.changeset(%User{}, %{points: points})
        Repo.insert!(changeset)
      end)

      assert {:reply, %{users: query_users}, _} = UserPoints.handle_call(:query, nil, default_args)

      assert Enum.count(query_users) == 2
      assert Enum.at(users, 0) in query_users
      assert Enum.at(users, 2) in query_users
    end
  end

  describe "handle_info/2 update_users_points_and_max_number" do
    setup do
      ten_seconds_ago = NaiveDateTime.utc_now() |> NaiveDateTime.add(-10) |> NaiveDateTime.truncate(:second)
      default_args = %{timestamp: ten_seconds_ago, max_number: 10, timeout: 10}
      {:ok, default_args: default_args}
    end

    test "updates all users", %{default_args: default_args} do
      users = Enum.map([15, 10, 11, 50], fn points ->
        changeset = User.changeset(%User{}, %{points: points})
        Repo.insert!(changeset)
      end)

      UserPoints.handle_info(:update_users_points_and_max_number, default_args)

      updated_users = Repo.all(User)

      assert Enum.map(users, &(&1.points)) != Enum.map(updated_users, &(&1.points))
    end

    test "sets max_number to number between 0..100", %{default_args: default_args} do
      args = Map.put(default_args, :max_number, -1)
      assert {:noreply, %{max_number: max}} = UserPoints.handle_info(:update_users_points_and_max_number, args)
      assert max in 0..100
    end

    test "sends update_users_points_and_max_number message", %{default_args: default_args} do
      UserPoints.handle_info(:update_users_points_and_max_number, default_args)
      assert_receive :update_users_points_and_max_number
    end
  end
end
