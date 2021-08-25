defmodule RemoteExercise.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :points, :integer

      timestamps()
    end

    create constraint("users", "poits_must_be_zero_to_hundred", check: "points >= 0 AND points <= 100")
  end
end
