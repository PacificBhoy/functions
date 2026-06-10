class CarDetails {
  // Define properties for the car details
  String make;
  String model;
  int year;

  // Constructor to initialize the properties
  CarDetails(this.make, this.model, this.year);

  // Method to display the details of the car
  void displayDetails() {
    print('Car: $make $model ($year)');
  }
}

class User {
  // Define a property for the username
  String Username;
  User(this.Username);

  void login() {
    // Simulate a user login by printing a message to the console
    print("$Username has logged in");
  }
}

class Admin extends User {
  // Define a property for the admin level
  int adminLevel;
  Admin(String username, this.adminLevel) : super(username);

  @override // Override the login method to include additional information about the admin level
  void login() {
    // Call the login method of the parent class (User) to maintain the base functionality
    print(
      "Security Alert: Admin $Username with level $adminLevel has logged in",
    );
  }
}

class person {
  String name;
  String sex;
  int age;

  person(this.name, this.sex, this.age);

  void showDetails() {
    print('Details: $name, Sex: $sex, Age: $age');
  }
}

void main() {
  // Create an instance of the CarDetails class and call the displayDetails method
  var myCar = CarDetails('Toyota', 'Camry', 2020);

  // Display the details of the car using the displayDetails method, which is a member function of the CarDetails class.
  myCar.displayDetails();

  var user1 = User(
    'Alice',
  ); // Create an instance of the User class and call the login method
  user1.login();

  var admin1 = Admin(
    'Bob',
    5,
  ); // Create an instance of the Admin class and call the login method, which is overridden to include additional information about the admin level.
  admin1.login();

  var person1 = person(
    'Charlie',
    'Male',
    30,
  ); // Create an instance of the person class and call the showDetails method
  person1.showDetails();
}
