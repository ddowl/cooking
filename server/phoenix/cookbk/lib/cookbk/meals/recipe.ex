defmodule Cookbk.Meals.Recipe do
  use Ecto.Schema
  import Ecto.Changeset
  alias Cookbk.Accounts.User
  alias Cookbk.Meals.RecipeStep

  schema "recipes" do
    field :description, :string
    field :name, :string
    belongs_to :user, User
    has_many :recipe_steps, RecipeStep

    timestamps()
  end

  @doc false
  def changeset(recipe, attrs) do
    recipe
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end