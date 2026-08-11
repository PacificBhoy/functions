---
name: flutter-ecommerce
description: Ecommerce patterns for the shopeasy Flutter app — catalog and product models, cart state, search and filtering, forms and validation, API serialization, and checkout flow. Use when building shopping features like product lists, cart, or checkout.
---

# Flutter Ecommerce (shopeasy)

Patterns for the shopping-specific parts of this app. Read the `flutter` skill first for general structure — this one covers what is particular to a store.

## Current state of this app

`lib/main.dart` holds everything: `MyApp`, `MyHomePage`, `CategoriesScreen`, `ProfileScreen`, and `CartScreen`. Categories and products are hardcoded `Map<String, String>` literals, prices are strings like `'$100'`, and "add to cart" shows an `AlertDialog` without storing anything — `CartScreen` is a placeholder that renders static text.

So when adding a shopping feature, the first move is usually to extract: models into `lib/models/`, screens into `lib/screens/`, cart state into `lib/state/`. Do not add a sixth screen class to `main.dart`.

## Domain models

Four types carry almost everything in a store:

```dart
class Category {
  final String id;
  final String name;
  final String imageUrl;
  const Category({required this.id, required this.name, required this.imageUrl});
}

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final int stock;          // count, not the string 'In Stock'
  final String categoryId;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.stock,
    required this.categoryId,
  });

  bool get inStock => stock > 0;
}

class CartItem {
  final Product product;
  final int quantity;
  const CartItem({required this.product, required this.quantity});

  double get lineTotal => product.price * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);
}
```

`stock` as an `int` rather than `'In Stock'` is what lets you cap quantity at what is actually available, and disable the add button precisely.

## Cart state

The cart is read and written from multiple screens, so it cannot live in one screen's `setState`. Use a `ChangeNotifier` provided above the navigator.

```dart
class CartModel extends ChangeNotifier {
  final Map<String, CartItem> _items = {};   // keyed by product id

  UnmodifiableListView<CartItem> get items => UnmodifiableListView(_items.values);
  int get count => _items.values.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => _items.values.fold(0.0, (sum, i) => sum + i.lineTotal);
  bool contains(String productId) => _items.containsKey(productId);

  void add(Product product, {int quantity = 1}) {
    final existing = _items[product.id];
    final desired = (existing?.quantity ?? 0) + quantity;
    if (desired > product.stock) return;               // never exceed stock
    _items[product.id] = CartItem(product: product, quantity: desired);
    notifyListeners();
  }

  void setQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      _items.remove(productId);
    } else {
      final item = _items[productId];
      if (item == null || quantity > item.product.stock) return;
      _items[productId] = item.copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
```

Key decisions baked in above:

- **Keyed by product id**, so adding the same product twice increments quantity instead of creating a duplicate row.
- **Quantity zero removes the line**, so the decrement button needs no special case.
- **Stock is enforced in the model**, not in the button's `onPressed` — every caller gets the check.

Money is `double` throughout and formatted only at render time, with `NumberFormat.simpleCurrency()` from `intl`. Never store a formatted price string.

## Cart badge

The cart icon in the app bar should show a live count. Wrap only the badge in the listener so the rest of the bar does not rebuild:

```dart
Consumer<CartModel>(
  builder: (context, cart, child) => Badge(
    isLabelVisible: cart.count > 0,
    label: Text('${cart.count}'),
    child: child,          // the IconButton, built once
  ),
  child: IconButton(icon: const Icon(Icons.shopping_cart), onPressed: _openCart),
)
```

Passing the unchanging `IconButton` as `child` keeps it out of the rebuild.

## Add-to-cart feedback

Prefer a `SnackBar` with an **Undo** action over a modal `AlertDialog`. A dialog interrupts browsing and requires a dismiss tap on every add; a snackbar confirms without blocking and makes the mistake cheap to reverse.

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('${product.name} added to cart'),
    action: SnackBarAction(
      label: 'Undo',
      onPressed: () => cart.setQuantity(product.id, 0),
    ),
  ),
);
```

Also: tapping a product tile should open a product **detail** screen. Reserve add-to-cart for an explicit button, so a mis-tap while scrolling does not silently add an item.

## Search and filtering

Keep the source list immutable and derive the filtered view — don't overwrite the master list, or a cleared search cannot restore it.

```dart
List<Product> get _visible {
  final q = _query.trim().toLowerCase();
  if (q.isEmpty) return _allProducts;
  return _allProducts.where((p) => p.name.toLowerCase().contains(q)).toList();
}
```

Debounce network-backed search by ~300ms with a `Timer` so each keystroke does not fire a request. Local in-memory filtering needs no debounce.

Always render an empty state — a screen that goes blank on "no results" reads as a bug.

## Product lists

Product grids scroll long, so build lazily with `GridView.builder`, and give each tile a `ValueKey(product.id)`.

Set a realistic `childAspectRatio`: a tile with an image plus name, price, and stock line needs roughly `0.7`, not `1.0`. At `1.0` the text overflows and you get yellow-and-black stripes.

Wrap prices and names in `Text(..., maxLines: 1, overflow: TextOverflow.ellipsis)` — product names from a real catalog are longer than the mock data suggests.

## Forms and checkout

Use a `Form` with a `GlobalKey<FormState>` and per-field `validator`s. Validate on submit, and set `autovalidateMode: AutovalidateMode.onUserInteraction` so errors appear as the user corrects them rather than only at the end.

Checkout order:

1. Cart review — line items, quantity steppers, subtotal.
2. Shipping address — validated form.
3. Payment.
4. Confirmation — order id, and clear the cart only after the backend confirms.

Disable the submit button while a request is in flight and show progress in place, or double-taps create duplicate orders. Re-check stock server-side at order time; client-side stock is always stale.

**Never implement real payment card entry by hand.** Use the payment provider's SDK or a hosted checkout, so raw card numbers never touch this app's code.

## API layer

Put HTTP in `lib/services/`, returning models — never let a screen parse JSON:

```dart
class CatalogService {
  Future<List<Product>> fetchProducts({String? categoryId}) async { ... }
}
```

Every list screen then has four states to render: loading, error with a retry action, empty, and populated. Handle all four; the error state is the one most often skipped, and it is the one users hit on a bad connection.

## Persistence

Persist the cart so it survives an app restart — `shared_preferences` with a JSON blob is enough at this size. Restore it on startup, and re-validate prices and stock against the server before checkout, since a saved cart may be days old.
