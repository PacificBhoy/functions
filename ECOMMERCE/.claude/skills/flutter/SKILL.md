---
name: flutter
description: Core guidance for building Flutter apps — project layout, widget composition, state management, navigation, async and streams, testing, and the build/run commands. Use when writing or reviewing any Dart/Flutter code in this project.
---

# Flutter

Guidance for writing Flutter code that stays readable as the app grows past one file.

## Project layout

`lib/main.dart` should hold `main()` and the root `App` widget, and little else. Everything else goes under `lib/`:

```
lib/
  main.dart          # runApp + root MaterialApp only
  models/            # plain Dart data classes
  screens/           # one file per full-page widget
  widgets/           # reusable pieces shared across screens
  services/          # API clients, storage, anything doing I/O
  state/             # controllers / notifiers
```

When a file passes ~200 lines or holds more than one screen, split it. A screen file that also defines three other screens is the first thing to break apart.

## Widgets

**Prefer `StatelessWidget`.** Reach for `StatefulWidget` only when the widget itself owns mutable state that nothing else needs. State that two screens both read belongs above them, not inside one of them.

**Extract widgets, don't extract build methods.** A private `Widget _buildCard()` method rebuilds with the whole parent. A separate `const`-constructible `ProductCard` widget does not. Extraction into classes is what actually buys you rebuild isolation.

**Use `const` everywhere it compiles.** `const` widgets are canonicalized and skipped during rebuild. `flutter_lints` flags the misses — treat those warnings as errors.

**Keys matter in lists.** Any list whose items can be reordered, inserted, or removed needs a stable `ValueKey` per item, or Flutter matches state to the wrong element. Never use the list index as a key in a mutable list.

**Modern constructor style:** use `super.key`, not `{Key? key}) : super(key: key)`. The older form still compiles but is deprecated style in current Dart.

```dart
const ProductCard({super.key, required this.product});
```

## State management

Match the tool to the scope:

| Scope | Use |
|---|---|
| One widget, ephemeral (a text field, a toggle) | `setState` |
| Shared across a few widgets in one subtree | `ValueNotifier` + `ValueListenableBuilder` |
| App-wide (cart, auth, settings) | `ChangeNotifier` + `provider`, or Riverpod |

Do not scatter `setState` across screens to fake shared state — copying a list into a second screen's field means the two go out of sync the moment either changes.

`ChangeNotifier` rules: mutate internal state, then call `notifyListeners()` once at the end. Expose collections as `UnmodifiableListView` so callers cannot mutate behind your back. Always `dispose()` notifiers and controllers.

## Models over `Map<String, String>`

An untyped map gives no autocomplete, no compile-time checking, and forces `!` on every read. Write a class:

```dart
class Product {
  final String id;
  final String name;
  final double price;     // a real number, not the string '$100'
  final bool inStock;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.inStock,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    inStock: json['inStock'] as bool,
  );
}
```

Keep money as `double` (or minor-unit `int`) and format at display time. Storing `'$100'` means you cannot compute a subtotal without parsing.

## Navigation

`Navigator.push` with `MaterialPageRoute` is fine for a handful of screens. Move to named routes or `go_router` once you need deep links, web URLs, or a nav stack you can reason about.

**Never use a `BuildContext` across an `await` without guarding it.** The widget may be gone:

```dart
await service.submit();
if (!context.mounted) return;
Navigator.pop(context);
```

## Async and streams

Use `FutureBuilder` / `StreamBuilder` for one-off loads, and handle all three states — data, error, and waiting. A builder that only checks `hasData` shows a spinner forever on failure.

Cancel `StreamSubscription`s in `dispose()`. Dispose every `TextEditingController`, `AnimationController`, and `ScrollController` you create — leaking them is the most common Flutter memory bug.

## Images and network

`Image.network` has no cache, no placeholder, and no error widget by default. For anything user-facing, supply `errorBuilder` and `loadingBuilder`, or use `cached_network_image`. A dead URL otherwise renders as a raw exception box in the UI.

URL shorteners as asset sources are fragile — they break silently and permanently. Prefer bundled assets in `assets/` (declared in `pubspec.yaml`) or a stable CDN.

## Layout

- `Expanded` / `Flexible` only work inside `Row`, `Column`, or `Flex`.
- Unbounded-height errors usually mean a `ListView` inside a `Column` — give it `Expanded`, or set `shrinkWrap: true` for short lists.
- Use `GridView.builder` / `ListView.builder` rather than the default constructors, so items build lazily.
- Wrap screen bodies in `SafeArea` where content can reach notches or system bars.

## Theming

Define colors, text styles, and shapes once in `ThemeData` on the root `MaterialApp`, then read them via `Theme.of(context)`. Hardcoding `TextStyle(fontSize: 18)` in twenty widgets makes a restyle a twenty-file edit.

`primarySwatch` is legacy. Use `ColorScheme.fromSeed(seedColor: ...)` with Material 3.

## Testing

`test/` mirrors `lib/`. Three kinds, in increasing cost:

- **Unit** — models, and pure logic like cart totals or filters. Fast, write many.
- **Widget** — `testWidgets` with `pumpWidget`, then `find.text(...)` / `find.byType(...)` and `expect(..., findsOneWidget)`. Call `await tester.pump()` after any interaction that triggers a rebuild.
- **Integration** — full flows, via `integration_test`. Slow, write few.

Pull business logic out of widgets specifically so it can be unit tested without pumping a widget tree.

## Commands

Run the app:

```bash
flutter run
```

Analyze and test before committing:

```bash
flutter analyze && flutter test
```

Format:

```bash
dart format lib test
```

Refresh dependencies after editing `pubspec.yaml`:

```bash
flutter pub get
```

Check the toolchain when builds behave oddly:

```bash
flutter doctor -v
```

Hot reload (`r` in the run console) preserves state and works for most build-method edits. Changes to `main()`, global variables, `initState`, or class declarations need a hot restart (`R`).
