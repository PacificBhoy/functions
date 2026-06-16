void main() {
  List<int> numbers = [1, 2, 3, 4, 5];
  for (int grade in numbers)
    if (grade >= 3) {
      print(
        'The Grade is: $grade',
      ); // This if statement will execute for grades 3 and above
    } else {
      print(
        'The Grade is below 3',
      ); // This else statement will display error message for grades below 3
    }

  List<double> figures = [1.5, 2.5, 3.5, 4.5, 5.5];
  for (double figure in figures.where((f) => f > 3.0)) {
    // Using where to filter figures greater than 3.0
    print('The Figure is: $figure');
  }
}
