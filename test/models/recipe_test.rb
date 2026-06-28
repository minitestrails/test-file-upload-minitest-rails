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

  test "attaches a photo" do
    recipe = recipes(:pancakes)
    file = file_fixture("sample.jpg")

    recipe.photo.attach(
      io: File.open(file),
      filename: "sample.jpg",
      content_type: "image/jpeg"
    )

    assert recipe.photo.attached?
    assert_equal "sample.jpg", recipe.photo.filename.to_s
    assert_equal "image/jpeg", recipe.photo.content_type
  end

  test "rejects a invalid content type" do
    recipe = Recipe.new(title: "Bad upload")
    file = file_fixture("sample.txt")

    recipe.photo.attach(
      io: File.open(file),
      filename: "sample.txt",
      content_type: "text/plain"
    )

    assert_not recipe.valid?
    assert_includes recipe.errors[:photo], "must be a JPEG or PNG"
  end

  test "pancakes fixture has a photo" do
    photo = recipes(:pancakes).photo

    assert photo.attached?
    assert_not_nil photo.download
  end
end
