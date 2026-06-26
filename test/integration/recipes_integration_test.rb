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

  test "creates a recipe with a photo" do
    assert_difference("Recipe.count", 1) do
      post recipes_path, params: {
        recipe: {
          title: "Pancakes with photo",
          photo: sample_photo_upload
        }
      }
    end

    recipe = Recipe.last
    assert_redirected_to recipe_path(recipe)
    follow_redirect!
    assert_response :success

    assert recipe.photo.attached?
    assert_equal "sample.jpg", recipe.photo.filename.to_s
  end

  test "updates a recipe's photo" do
    recipe = recipes(:lentil_soup)
    recipe.photo.attach(
      io: file_fixture("sample.jpg").open,
      filename: "old.jpg",
      content_type: "image/jpeg"
    )
    original_blob_id = recipe.photo.blob.id

    patch recipe_path(recipe), params: {
      recipe: { photo: sample_photo_upload }
    }

    assert_redirected_to recipe_path(recipe)
    recipe.reload

    assert recipe.photo.attached?
    assert_equal "sample.jpg", recipe.photo.filename.to_s
    assert_not_equal original_blob_id, recipe.photo.blob.id
  end
end
