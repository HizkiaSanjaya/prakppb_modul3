import 'package:flutter/foundation.dart';
import 'country.dart';

class HistoryStore extends ChangeNotifier {
  HistoryStore._();
  static final HistoryStore instance = HistoryStore._();

  final List<Country> _items = [];

  List<Country> get items => List.unmodifiable(_items);

  void add(Country country) {
    // Hapus jika sudah ada sebelumnya agar posisi terkini ada di urutan teratas
    _items.removeWhere((c) => c.name == country.name);
    _items.insert(0, country);
    notifyListeners();
  }

  void removeAt(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  // Hard delete seluruh riwayat
  void clearAll() {
    _items.clear();
    notifyListeners();
  }
}
