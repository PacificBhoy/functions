// Importing the necessary Flutter material package
import 'package:flutter/material.dart';

// Screens that make up the start up and authentication flow
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  // Entry point of the application, runApp function starts the app
  runApp(const MyApp());
}

// MyApp class which is the root of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp provides the structure for the app
    return MaterialApp(
      title: 'Shopeasy', // Title of the application
      theme: ThemeData(
        primarySwatch: Colors.blue, // Primary color theme
        scaffoldBackgroundColor: const Color(0xFFF5F5DC), // Background color
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      initialRoute: '/', // App starts on the splash screen
      // Named routes let any screen navigate by name instead of building the
      // widget itself, so the auth screens never need to import the home page.
      routes: {
        '/': (context) => const SplashScreen(), // Splash, decides where to go
        '/login': (context) => const LoginScreen(), // Sign in
        '/signup': (context) => const SignupScreen(), // Create account
        '/home': (context) => const MyHomePage(), // Existing home page
      },
    );
  }
}

// MyHomePage class representing the home page of the app
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController(); // Controller for search input

  // List of categories with names and image URLs.
  // These are direct URLs rather than shortened links: the shortener adds a
  // redirect hop, and on web the browser blocks any image whose host does not
  // send CORS headers. Every host below serves Access-Control-Allow-Origin: *.
  List<Map<String, String>> categories = [
    {
      'name': 'Electronics',
      'image': 'https://m.media-amazon.com/images/I/717tC4Mk9SL._AC_SL1000_.jpg',
    },
    {
      'name': 'Clothing',
      'image':
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=600&auto=format&fit=crop&q=60',
    },
    {
      'name': 'Shoes',
      'image':
          'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=600&auto=format&fit=crop&q=60',
    },
    {
      'name': 'Books',
      'image':
          'https://i.guim.co.uk/img/media/77e3e93d6571da3a5d77f74be57e618d5d930430/0_0_2560_1536/master/2560.jpg?width=1200&height=900&quality=85&auto=format&fit=crop&s=c99740fab952ee29d238d75272b98a61',
    },
    {
      'name': 'Home & Kitchen',
      'image':
          'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=600&auto=format&fit=crop&q=60',
    },
    {
      'name': 'Toys',
      'image':
          'https://plus.unsplash.com/premium_photo-1684623605166-1a7f751d20fa?w=600&auto=format&fit=crop&q=60',
    },
  ];

  List<Map<String, String>> displayedCategories = []; // List of categories to display

  @override
  void initState() {
    super.initState();
    displayedCategories = List.from(categories); // Initialize displayed categories
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopeasy'), // Title of the app bar
        actions: <Widget>[
          // Search bar
          SizedBox(
            width: 200,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Categories...',
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
              onChanged: _filterCategories, // Filter categories as the user types
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person), // Profile icon
            onPressed: () {
              // Navigate to profile screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart), // Cart icon
            onPressed: () {
              // Navigate to cart screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CartScreen(),
                ),
              );
            },
          ),
        ],
      ),
      // GridView to display categories
      body: GridView.builder(
        padding: const EdgeInsets.all(10.0), // Padding for the grid
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns in the grid
          crossAxisSpacing: 10.0, // Spacing between columns
          mainAxisSpacing: 10.0, // Spacing between rows
          childAspectRatio: 1.0, // Aspect ratio of each tile (width / height)
        ),
        itemCount: displayedCategories.length, // Number of items in the grid
        itemBuilder: (BuildContext context, int index) {
          // GestureDetector to handle taps on the category tiles
          return GestureDetector(
            onTap: () {
              // Navigate to category screen with the selected category
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoriesScreen(category: displayedCategories[index]['name']!),
                ),
              );
            },
            child: Card(
              elevation: 3.0, // Elevation of the card
              child: Column(
                children: [
                  Expanded(
                    // Display category image
                    child: Image.network(
                      displayedCategories[index]['image']!,
                      fit: BoxFit.cover,
                      // Without these, a failed or slow load throws into the
                      // console and leaves the tile blank.
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const ColoredBox(
                          color: Color(0xFFEEEEEE),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const ColoredBox(
                          color: Color(0xFFEEEEEE),
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0), // Padding around the text
                    child: Text(
                      displayedCategories[index]['name']!, // Display category name
                      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Function to filter categories based on search input
  void _filterCategories(String query) {
    if (query.isEmpty) {
      setState(() {
        displayedCategories = List.from(categories);
      });
      return;
    }
    final filtered = categories.where((category) {
      final categoryName = category['name']!.toLowerCase();
      final searchLower = query.toLowerCase();
      return categoryName.contains(searchLower);
    }).toList();

    setState(() {
      displayedCategories = filtered;
    });
  }
}

// Screen to display the products of a specific category
class CategoriesScreen extends StatelessWidget {
  final String category;

  const CategoriesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Dummy list of products with details
    List<Map<String, String>> products = [
      {'name': 'Product 1', 'price': '\$100', 'stock': 'In Stock', 'description': 'Description 1'},
      {'name': 'Product 2', 'price': '\$150', 'stock': 'In Stock', 'description': 'Description 2'},
      {'name': 'Product 3', 'price': '\$200', 'stock': 'Out of Stock', 'description': 'Description 3'},
      {'name': 'Product 4', 'price': '\$250', 'stock': 'In Stock', 'description': 'Description 4'},
      {'name': 'Product 5', 'price': '\$300', 'stock': 'In Stock', 'description': 'Description 5'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(category), // Title of the app bar
        centerTitle: true, // Center the title
      ),
      // GridView to display products
      body: GridView.builder(
        padding: const EdgeInsets.all(10.0), // Padding for the grid
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns in the grid
          crossAxisSpacing: 10.0, // Spacing between columns
          mainAxisSpacing: 10.0, // Spacing between rows
          childAspectRatio: 1.0, // Aspect ratio of each tile (width / height)
        ),
        itemCount: products.length, // Number of items in the grid
        itemBuilder: (BuildContext context, int index) {
          // GestureDetector to handle taps on the product tiles
          return GestureDetector(
            onTap: () {
              // Add the product to the cart
              _addToCart(context, products[index]);
            },
            child: Card(
              elevation: 3.0, // Elevation of the card
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Padding around the text
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the content
                  children: [
                    Text(
                      products[index]['name']!, // Display product name
                      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      products[index]['price']!, // Display product price
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      products[index]['stock']!, // Display product stock status
                      style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Function to add the product to the cart
  void _addToCart(BuildContext context, Map<String, String> product) {
    // Implement logic to add the product to the cart
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Item Added to Cart'), // Alert dialog title
          content: Text('${product['name']} has been added to your cart.'), // Alert dialog content
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'), // OK button
            ),
          ],
        );
      },
    );
  }
}

// Dummy ProfileScreen class to represent the user profile
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'), // Title of the app bar
        centerTitle: true, // Center the title
      ),
      body: const Center(
        child: Text('User Profile Screen'), // Text content of the profile screen
      ),
    );
  }
}

// Dummy CartScreen class to represent the shopping cart
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'), // Title of the app bar
        centerTitle: true, // Center the title
      ),
      body: const Center(
        child: Text('Shopping Cart Screen'), // Text content of the shopping cart screen
      ),
    );
  }
}
