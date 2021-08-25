defmodule RemoteExercise.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :points, :integer

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:points])
    |> validate_required([:points])
    |> check_constraint(:points, name: :poits_must_be_zero_to_hundred, message: "must be between 0 and 100")
  end
end
