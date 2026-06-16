void main() {
  var recipe = SecretRecipe('Isaac Spag recipe', 'fresh spices', 'garlic');
  print(recipe);
}

class Recipe {
  String name;
  String mainIngredient;

  Recipe(this.name, this.mainIngredient);

  // We use @override to tell Dart we are replacing Object's default method
  @override
  String toString() {
    return '$name (Main ingredient: $mainIngredient)';
  }
}

class SecretRecipe extends Recipe {
  String secretSpice;
  // We use super to call the parent class's constructor
  SecretRecipe(String name, String mainIngredient, this.secretSpice)
      : super(name, mainIngredient);

  @override
  String toString() {
    // We use super.toString() to grab the parent's formatted string, then add to it!
    return '${super.toString()} - SHHH! Contains $secretSpice!';
  }
}
