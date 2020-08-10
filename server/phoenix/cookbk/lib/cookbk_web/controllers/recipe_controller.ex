defmodule CookbkWeb.RecipeController do
  use CookbkWeb, :controller

  alias Cookbk.Meals
  alias Cookbk.Meals.Recipe
  alias Cookbk.Meals.RecipeStep
  alias Phoenix.LiveView
  import Phoenix.LiveView.Controller
  import Logger

  def index(conn, _params) do
    recipes = Meals.list_recipes()
    render(conn, "index.html", recipes: recipes)
  end

  def new(conn, _params) do
    live_render(conn, CookbkWeb.RecipeLive, session: %{"debug" => conn.assigns.debug})
  end

  def create(conn, %{"recipe" => recipe_params}) do
    current_user = conn.assigns.current_user

    # Add order ID to changeset from UI ordering
    recipe_params =
      update_in(recipe_params, ["recipe_steps"], fn steps ->
        steps
        |> Enum.map(fn {i, data} -> {i, Map.put(data, "order_id", i)} end)
        |> Enum.into(%{})
      end)

    Logger.info(inspect(recipe_params))

    case Meals.create_recipe(current_user, recipe_params) do
      {:ok, recipe} ->
        conn
        |> put_flash(:info, "Recipe created successfully.")
        |> redirect(to: Routes.user_recipe_path(conn, :show, current_user, recipe))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    recipe = Meals.get_recipe!(id)
    render(conn, "show.html", recipe: recipe)
  end

  def edit(conn, %{"id" => id}) do
    recipe = Meals.get_recipe!(id)
    changeset = Meals.change_recipe(recipe)
    render(conn, "edit.html", recipe: recipe, changeset: changeset)
  end

  def update(conn, %{"id" => id, "recipe" => recipe_params}) do
    recipe = Meals.get_recipe!(id)
    current_user = conn.assigns.current_user

    # Add order ID to changeset from UI ordering
    Logger.info(inspect(recipe_params))

    steps = Map.get(recipe_params, "recipe_steps")

    Logger.info(inspect(steps))

    recipe_params =
      if is_nil(steps) do
        recipe_params
      else
        ordered_steps =
          steps
          |> Enum.with_index()
          |> Enum.map(fn {{_order_id, data}, i} -> {i, Map.put(data, "order_id", i)} end)
          |> Enum.into(%{})

        Map.put(recipe_params, "recipe_steps", ordered_steps)
      end

    Logger.info(inspect(recipe_params))

    case Meals.update_recipe(current_user, recipe, recipe_params) do
      {:ok, recipe} ->
        conn
        |> put_flash(:info, "Recipe updated successfully.")
        |> redirect(to: Routes.user_recipe_path(conn, :show, current_user, recipe))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", recipe: recipe, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    recipe = Meals.get_recipe!(id)
    {:ok, _recipe} = Meals.delete_recipe(recipe)

    conn
    |> put_flash(:info, "Recipe deleted successfully.")
    |> redirect(to: Routes.user_recipe_path(conn, :index, conn.assigns.current_user))
  end
end
