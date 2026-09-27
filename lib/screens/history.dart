import 'package:flutter/material.dart';
import '../models/country.dart';
import '../models/history_store.dart';
import 'detail.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  void _confirmHardDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Hard Delete'),
          content: const Text(
            'Apakah anda yakin ingin menghapus seluruh riwayat kunjungan negara secara permanen?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                HistoryStore.instance.clearAll();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Semua riwayat berhasil dihapus secara permanen.'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Hapus Semua'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Kunjungan'),
        actions: [
          ListenableBuilder(
            listenable: HistoryStore.instance,
            builder: (context, _) {
              if (HistoryStore.instance.items.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.delete_forever),
                tooltip: 'Hard Delete Riwayat',
                onPressed: () => _confirmHardDelete(context),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: HistoryStore.instance,
        builder: (context, _) {
          final historyList = HistoryStore.instance.items;
          if (historyList.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada riwayat negara yang dibuka',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: historyList.length,
            itemBuilder: (context, i) {
              final Country country = historyList[i];
              return Dismissible(
                key: Key('${country.name}_$i'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  HistoryStore.instance.removeAt(i);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${country.name} dihapus dari riwayat.'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: country.flagsPng != null
                        ? Image.network(country.flagsPng!, width: 50)
                        : const SizedBox(width: 50),
                    title: Text(country.name),
                    subtitle: Text(country.region),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                      tooltip: 'Hapus satu riwayat',
                      onPressed: () => HistoryStore.instance.removeAt(i),
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
