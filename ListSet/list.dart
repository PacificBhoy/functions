void main() {
  List<String> fruits = ['Apple', 'Banana', 'Cherry'];
  print(fruits); // Output: [Apple, Banana, Cherry]

  fruits.add('Date');
  print(fruits); // Output: [Apple, Banana, Cherry, Date]

  fruits.remove('Banana');
  print(fruits); // Output: [Apple, Cherry, Date]

  print(fruits[0]); // Output: Apple

  print(fruits.indexOf('Cherry')); // Output: 1

  List<int> numbers = [1, 2, 3, 4, 5];

  numbers[2] = 10; // Modifying the element at index 2
  print(numbers[2]); // Output: 10

  numbers.removeLast(); // Removing the last element from the list
  print(numbers); // Output: [1, 2, 10, 4]

  print(numbers.length); // display total number of elements Output: 4

  Set<String> uniqueCars = {'Toyota', 'Honda', 'Ford', 'GMC'};
  print(uniqueCars); // Output: {Toyota, Honda, Ford, GMC}

  uniqueCars.add('BMW');
  print(uniqueCars); // Output: {Toyota, Honda, Ford, GMC, BMW}

  print(uniqueCars.length); // Output: 5
}
