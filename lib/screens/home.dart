import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import '../models/country.dart';
import '../models/favorites_store.dart';
import '../models/history_store.dart';
import 'detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Country>> countries;
  String _query = '';
  String _selectedRegion = 'Semua Benua';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    countries = fetchCountries();
  }

  Future<List<Country>> fetchCountries() async {
    final uri = Uri.parse('https://www.apicountries.com/countries');
    final request = await HttpClient().getUrl(uri);
    final response = await request.close();

    if (response.statusCode == 200) {
      final respBody = await response.transform(utf8.decoder).join();
      final List jsonData = jsonDecode(respBody);
      return jsonData.map((j) => Country.fromJson(j)).toList();
    } else {
      throw Exception('Failed to load countries: ${response.statusCode}');
    }
  }

  List<Country> _processData(List<Country> list) {
    // 1. Filter nama
    final q = _query.trim().toLowerCase();
    var filtered = list.where((c) {
      final matchQuery = q.isEmpty || c.name.toLowerCase().contains(q);
      final matchRegion = _selectedRegion == 'Semua Benua' || c.region == _selectedRegion;
      return matchQuery && matchRegion;
    }).toList();

    // 2. Sorting berdasarkan Benua (Region) lalu Nama Negara
    filtered.sort((a, b) {
      final regionCompare = a.region.compareTo(b.region);
      if (regionCompare != 0) {
        return _sortAscending ? regionCompare : -regionCompare;
      }
      return a.name.compareTo(b.name);
    });

    return filtered;
  }

  List<String> _extractRegions(List<Country> list) {
    final Set<String> regions = {'Semua Benua'};
    for (final c in list) {
      if (c.region.isNotEmpty) {
        regions.add(c.region);
      }
    }
    return regions.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countries'),
        actions: [
          IconButton(
            icon: Icon(_sortAscending ? Icons.sort_by_alpha : Icons.sort),
            tooltip: _sortAscending ? 'Urutkan Benua: A-Z' : 'Urutkan Benua: Z-A',
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Country>>(
        future: countries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No countries found'));
          }

          final rawList = snapshot.data!;
          final regions = _extractRegions(rawList);
          final list = _processData(rawList);

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Cari negara...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _query = ''),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),

              // Filter & Sorting Bar berdasarkan Benua
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.public, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('Benua: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: regions.contains(_selectedRegion) ? _selectedRegion : 'Semua Benua',
                          isExpanded: true,
                          items: regions.map((String reg) {
                            return DropdownMenuItem<String>(
                              value: reg,
                              child: Text(reg, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (String? newVal) {
                            if (newVal != null) {
                              setState(() {
                                _selectedRegion = newVal;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    Text(
                      '${list.length} negara',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Daftar Negara
              Expanded(
                child: list.isEmpty
                    ? const Center(child: Text('Negara tidak ditemukan'))
                    : ListenableBuilder(
                        listenable: FavoritesStore.instance,
                        builder: (context, _) {
                          return ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (context, i) {
                              final country = list[i];
                              final isFav = FavoritesStore.instance.contains(country);
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                child: ListTile(
                                  leading: country.flagsPng != null
                                      ? Image.network(country.flagsPng!, width: 50)
                                      : const SizedBox(width: 50),
                                  title: Text(
                                    country.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text('Benua: ${country.region}'),
                                  trailing: IconButton(
                                    icon: Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? Colors.red : null,
                                    ),
                                    tooltip: isFav ? 'Hapus dari favorit' : 'Tambah ke favorit',
                                    onPressed: () => FavoritesStore.instance.toggle(country),
                                  ),
                                  onTap: () {
                                    // Catat kunjungan ke dalam Riwayat
                                    HistoryStore.instance.add(country);
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
              ),
            ],
          );
        },
      ),
    );
  }
}
