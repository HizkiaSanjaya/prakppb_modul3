import 'package:flutter/foundation.dart';
import 'country.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore._();
  static final FavoritesStore instance = FavoritesStore._();

  final List<Country> _items = [];

  List<Country> get items => List.unmodifiable(_items);

  bool contains(Country country) => _items.any((c) => c.name == country.name);

  void toggle(Country country) {
    if (contains(country)) {
      _items.removeWhere((c) => c.name == country.name);
    } else {
      _items.add(country);
    }
    notifyListeners();
  }
}
