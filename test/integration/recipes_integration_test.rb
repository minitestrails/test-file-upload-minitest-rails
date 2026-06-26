require "test_helper"

class RecipesIntegrationTest < ActionDispatch::IntegrationTest
  test "visits the list" do
    get recipes_url
    assert_response :success
    assert_match recipes(:pancakes).title, response.body
    assert_select "#recipes div[id^='recipe_']", count: Recipe.count
  end

  test "creates a recipe" do
    get new_recipe_url
    assert_response :success

    assert_difference("Recipe.count", 1) do
      post recipes_url, params: { recipe: { title: "Lentil soup" } }
    end

    assert_redirected_to recipe_url(Recipe.last)
    follow_redirect!
    assert_response :success
  end

  test "shows a recipe" do
    get recipe_url(recipes(:pancakes))
    assert_response :success
  end

  test "updates a recipe" do
    recipe = recipes(:pancakes)

    get edit_recipe_url(recipe)
    assert_response :success

    patch recipe_url(recipe), params: { recipe: { title: "Extra fluffy pancakes" } }
    assert_redirected_to recipe_url(recipe)
    follow_redirect!
    assert_response :success
    assert_equal "Extra fluffy pancakes", recipe.reload.title
  end

  test "destroys a recipe" do
    recipe = recipes(:lentil_soup)

    assert_difference("Recipe.count", -1) do
      delete recipe_url(recipe)
    end
    assert_redirected_to recipes_url
  end

  test "does not create a recipe with invalid data" do
    assert_no_difference("Recipe.count") do
      post recipes_url, params: { recipe: { title: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "does not update a recipe with invalid data" do
    recipe = recipes(:pancakes)

    patch recipe_url(recipe), params: { recipe: { title: "" } }
    assert_response :unprocessable_entity
    assert_equal "Pancakes", recipe.reload.title
  end
end
