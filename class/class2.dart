void main() {
  var menu1 = menuItem('Burger', 50); // Create an instance of the menuItem class and call the format method to display the menu item details in a formatted string.

  var menu2 = pizza('Pizza', 100, ['Large'], ['Pepperoni']); // Create an instance of the pizza class, which is a subclass of menuItem, and call the format method to display the pizza details in a formatted string.

  print(menu1.format()); // Call the format method of the menuItem instance to display the details of the menu item in a formatted string.
  print(menu2.format()); // Call the format method of the pizza instance to display the details of the pizza in a formatted string, which is inherited from the menuItem class.
}

class menuItem {
  String name;
  int price;

  menuItem(this.name, this.price); // Constructor to initialize the properties of the menu item.

  String format() {
    return '$name -->  \$$price'; // Method to format the menu item details into a string that includes the name and price of the item.
  }
}

class pizza extends menuItem {
  List<String> size, toppings; // Define additional properties for the pizza class, which is a subclass of menuItem, to include the size and toppings of the pizza.

  pizza(String name, int price, this.size, this.toppings) : super(name, price,); // Constructor for the pizza class that initializes the properties of the pizza and calls the constructor of the parent class (menuItem) to initialize the name and price properties.
}

