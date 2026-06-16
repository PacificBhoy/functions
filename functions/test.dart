void main() {
  /*for (var i = 0; i < 5; i++) {
    print('Iteration: $i');
  }
  print('Hello, World from test.dart!');

  int age = 30;
  age = 35;
  print('Age: $age');

  String name = 'Alice';
  name = 'Bob';
  print('Name: $name');

  bool isActive = true;
  isActive = false;
  print('Is Active: $isActive');*/

  final String message = greet(
    age: 20,
    name: 'Charlie',
  ); // Using named parameters with the greet function, position of parameters does not matter.
  print(message);

  final double area = calculateArea(
    5.0,
    3.0,
  ); // Using positional parameters with the calculateArea function, position of parameters matters.
  print(area);

  final String greeting = sayHello(
    'Dave',
    timeofDay: 'morning',
  ); //optional paramter timeofDay is provided
  print(greeting);

  final String pizzaOrder = orderPizza(
    size: 'large',
  ); //optional parameter topping is not provided, so it will use the default value 'cheese'
  print(pizzaOrder);
}

String greet({String? name, required int age}) {
  //named parameters with one required parameter (age) and one optional parameter (name)
  return 'Hello, $name! You are $age years old.';
}

double calculateArea(double width, double height) {
  //positional parameters with one required parameter (width) and one required parameter (height)
  return width * height;
}

String sayHello(String name, {String? timeofDay}) {
  //name is required while timeofDay is optional
  if (timeofDay != null) {
    //to check if parameter timeofDay is provided or not.
    return 'Good $timeofDay, $name!'; //if timeofDay is provided, it will return a greeting based on the time of day.
  } else {
    return 'Hello, $name!'; //if timeofDay is not provided, it will return a generic greeting Hello and the name.
  }
}

String orderPizza({required String size, String topping = 'cheese'}) {
  //required named parameter size and optional named parameter topping with a default value of 'cheese'
  return 'You ordered a $size pizza with $topping.';
}
