Recipe.find_or_create_by!(title: "Pancakes") do |recipe|
  recipe.description = "Fluffy buttermilk pancakes"
  recipe.servings = 4
  recipe.prep_time = 15
end
