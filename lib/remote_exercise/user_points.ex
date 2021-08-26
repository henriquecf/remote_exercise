defmodule RemoteExercise.UserPoints do
  use GenServer

  import Ecto.Query, only: [from: 2]
  alias RemoteExercise.Repo
  alias RemoteExercise.Accounts.User

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    max_number = Keyword.get(opts, :max_number, generate_random_number())
    timeout = Keyword.get(opts, :timeout, 60_000)
    initial_state = %{max_number: max_number, timestamp: nil, timeout: timeout}
    schedule_update_users_points_and_max_number(initial_state)
    {:ok, initial_state}
  end

  @impl true
  def handle_call(:query, _from, state) do
    query = from user in User,
      where: user.points > ^state.max_number,
      limit: 2

    users = Repo.all(query)
    {:reply, %{users: users, timestamp: state.timestamp}, update_timestamp(state)}
  end

  @impl true
  def handle_info(:update_users_points_and_max_number, state) do
    query = from u in User,
      update: [
        set: [
          points: fragment("floor(random() * 101)::int"),
          updated_at: fragment("NOW() at time zone 'utc'")
        ]
      ]

    Repo.update_all(query, [])

    schedule_update_users_points_and_max_number(state)
    {:noreply, Map.put(state, :max_number, generate_random_number())}
  end

  defp schedule_update_users_points_and_max_number(state) do
    Process.send_after(self(), :update_users_points_and_max_number, state.timeout)
  end

  defp generate_random_number() do
    Enum.random(0..100)
  end

  defp update_timestamp(state) do
    Map.put(state, :timestamp, NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second))
  end
end
