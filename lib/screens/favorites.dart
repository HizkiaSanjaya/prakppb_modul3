import 'package:flutter/material.dart';
import '../models/favorites_store.dart';
import 'detail.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Negara Favorit')),
      body: ListenableBuilder(
        listenable: FavoritesStore.instance,
        builder: (context, _) {
          final favorites = FavoritesStore.instance.items;
          if (favorites.isEmpty) {
            return const Center(child: Text('Belum ada negara favorit'));
          }
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, i) {
              final country = favorites[i];
              return Card(
                child: ListTile(
                  leading: country.flagsPng != null
                      ? Image.network(country.flagsPng!, width: 50)
                      : const SizedBox(width: 50),
                  title: Text(country.name),
                  subtitle: Text(country.region),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => FavoritesStore.instance.toggle(country),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(country: country),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
