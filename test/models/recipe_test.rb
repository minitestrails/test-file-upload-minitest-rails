require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  test "fixture recipe is valid" do
    assert recipes(:pancakes).valid?
  end

  test "requires a title" do
    recipe = Recipe.new(title: "")

    assert_not recipe.valid?
    assert_includes recipe.errors[:title], "can't be blank"
  end

  test "rejects a non-positive prep_time" do
    recipe = Recipe.new(title: "Soup", prep_time: 0)

    assert_not recipe.valid?
    assert_includes recipe.errors[:prep_time], "must be greater than 0"
  end

  test "allows a nil prep_time" do
    recipe = Recipe.new(title: "Soup", prep_time: nil)

    assert recipe.valid?
  end

  test "rejects a non-positive servings" do
    recipe = Recipe.new(title: "Soup", servings: 0)

    assert_not recipe.valid?
    assert_includes recipe.errors[:servings], "must be greater than 0"
  end

  test "allows a nil servings" do
    recipe = Recipe.new(title: "Soup", servings: nil)

    assert recipe.valid?
  end
end
