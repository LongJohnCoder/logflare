defmodule Logflare.Repo.Migrations.AddBigqueryDatasetLocation do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:bigquery_dataset_location, :string)
    end
  end
end
