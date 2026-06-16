void main() {
  Map<int, String> planets = {
    1: "Mercury",
    2: "Venus",
    3: "Earth",
    4: "Mars",
    5: "Jupiter",
    6: "Saturn",
    7: "Uranus",
    8: "Neptune",
  };
  planets[1] = "Ursa"; // Modifying the value associated with key 1

  planets[9] = "Pluto"; // Adding a new key-value pair to the map

  print(planets[1]); // Output: Ursa

  print(planets[9]); // Output: Pluto

  print(planets.containsKey(10)); // checking if key 10 exists in the map Output: false

  print(planets.containsValue("Earth")); // checking if value "Earth" exists in the map Output: true

  planets.remove(2); // Removing the key-value pair with key 2 (Venus)

  print(planets); // Output: {1: Ursa, 3: Earth, 4: Mars, 5: Jupiter, 6: Saturn, 7: Uranus, 8: Neptune, 9: Pluto}
}
