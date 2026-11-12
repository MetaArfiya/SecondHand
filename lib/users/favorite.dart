import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'favorite_store.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  // Warna Kustom
  final Color darkBlue = AppTheme.primaryPurple;
  final Color limeGreen = AppTheme.accentLavender;
  final Color tealText = AppTheme.secondaryPurple;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  String _sortOrder = 'Relevan';
  final TextEditingController _searchController = TextEditingController();



  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- BODY ---
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchAndFilter(),
              const SizedBox(height: 10),
              _buildCategories(),
              const SizedBox(height: 20),
              _buildFavoriteHeader(),
              _buildFavoriteGrid(),
              const SizedBox(height: 80), // Spasi bawah
            ],
          ),
        ),
      ),
    );
  }

  // Search and filter controls for the favorites list.
  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value.trim()),
              decoration: InputDecoration(
                hintText: 'Cari barang favorit...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus pencarian',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 48,
            width: 48,
            child: IconButton.filledTonal(
              tooltip: 'Filter barang favorit',
              onPressed: _showFilters,
              icon: const Icon(Icons.tune),
            ),
          ),
        ],
      ),
    );
  }
  // WIDGET: KATEGORI
  // ==========================================
  Widget _buildCategories() {
    final categories = <({IconData icon, String label})>[
      (icon: Icons.apps, label: 'Semua'),
      (icon: Icons.directions_car, label: 'Mobil'),
      (icon: Icons.motorcycle, label: 'Motor'),
      (icon: Icons.pedal_bike, label: 'Sepeda'),
      (icon: Icons.smartphone, label: 'HP'),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Telusuri kategori',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: Text('Lihat semua', style: TextStyle(color: tealText)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categories.map((category) {
              final isActive = _selectedCategory == category.label;
              return InkWell(
                onTap: () => setState(() => _selectedCategory = category.label),
                borderRadius: BorderRadius.circular(28),
                child: Semantics(
                  button: true,
                  selected: isActive,
                  label: 'Kategori ${category.label}',
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? limeGreen : Colors.grey.shade100,
                          border: Border.all(
                            color: isActive ? limeGreen : Colors.grey.shade300,
                          ),
                        ),
                        child: Icon(
                          category.icon,
                          color: isActive ? darkBlue : Colors.grey.shade600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.w500,
                          color: isActive ? Colors.black : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET: HEADER FAVORIT
  // ==========================================
  Widget _buildFavoriteHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KOLEKSIMU',
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5),
              ),
              Text(
                _selectedCategory == 'Semua'
                    ? 'Barang favorit'
                    : 'Favorit kategori $_selectedCategory',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          TextButton(
            onPressed: _resetFilters,
            child: Text('Lihat semua', style: TextStyle(color: tealText)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET: GRID FAVORIT
  // ==========================================
  Widget _buildFavoriteGrid() {
    return ValueListenableBuilder<List<Map<String, Object>>>(
      valueListenable: FavoriteStore.items,
      builder: (context, allFavorites, _) {
        final query = _searchQuery.toLowerCase();
        final favorites = allFavorites.where((product) {
          final matchesCategory = _selectedCategory == 'Semua' ||
              product['category'] == _selectedCategory;
          final searchableText =
              '${product['title']} ${product['category']} ${product['location']}'
                  .toLowerCase();
          return matchesCategory && searchableText.contains(query);
        }).toList();
        if (_sortOrder == 'Harga terendah') {
          favorites.sort((a, b) => _priceValue(a['price'] as String)
              .compareTo(_priceValue(b['price'] as String)));
        } else if (_sortOrder == 'Harga tertinggi') {
          favorites.sort((a, b) => _priceValue(b['price'] as String)
              .compareTo(_priceValue(a['price'] as String)));
        }

        if (favorites.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.favorite_border,
                      size: 42, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Tidak ada barang yang cocok dengan pencarian.'
                        : 'Belum ada barang favorit di kategori ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  TextButton(
                      onPressed: _resetFilters,
                      child: const Text('Lihat semua')),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
            children: favorites
                .map((product) => _buildProductCard(
                      product['title']! as String,
                      product['price']! as String,
                      product['location']! as String,
                      product['time']! as String,
                      product['image']! as String,
                      isFeatured: product['featured']! as bool,
                      imageBytes: product['imageBytes'],
                    ))
                .toList(),
          ),
        );
      },
    );
  }
  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _selectedCategory = 'Semua';
      _searchQuery = '';
      _sortOrder = 'Relevan';
    });
  }

  int _priceValue(String price) =>
      int.parse(price.replaceAll(RegExp(r'[^0-9]'), ''));

  void _removeFavorite(String title) {
    final index = FavoriteStore.items.value
        .indexWhere((product) => product['title'] == title);
    if (index < 0) return;
    final removedProduct =
        Map<String, Object>.from(FavoriteStore.items.value[index]);
    FavoriteStore.remove(title);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Expanded(child: Text('$title dihapus dari favorit.')),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                FavoriteStore.restore(removedProduct, index);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Urungkan'),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _showProductDetails(String title) async {
    final product = FavoriteStore.items.value
        .firstWhere((item) => item['title'] == title);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(product['title']! as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product['category']! as String),
            const SizedBox(height: 8),
            Text(product['price']! as String,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${product['location']} • ${product['time']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              _removeFavorite(title);
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Hapus favorit'),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilters() async {
    var category = _selectedCategory;
    var sortOrder = _sortOrder;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter barang favorit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Kategori'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Semua', 'Mobil', 'Motor', 'Sepeda', 'HP']
                      .map((item) => ChoiceChip(
                            label: Text(item),
                            selected: category == item,
                            onSelected: (_) =>
                                setSheetState(() => category = item),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                const Text('Urutkan harga'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Relevan', 'Harga terendah', 'Harga tertinggi']
                      .map((item) => ChoiceChip(
                            label: Text(item),
                            selected: sortOrder == item,
                            onSelected: (_) =>
                                setSheetState(() => sortOrder = item),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = category;
                        _sortOrder = sortOrder;
                      });
                      Navigator.pop(sheetContext);
                    },
                    child: const Text('Terapkan filter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(String title, String price, String location,
      String time, String imageUrl,
      {required bool isFeatured, Object? imageBytes}) {
    return InkWell(
      onTap: () => _showProductDetails(title),
      borderRadius: BorderRadius.circular(10),
      child: Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: imageBytes is Uint8List
                    ? Image.memory(
                        imageBytes,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        imageUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 120,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
              ),
              if (isFeatured)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: limeGreen, // Warna hijau lime sesuai gambar
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.local_offer, size: 8, color: Colors.black), // Ikon label
                        SizedBox(width: 2),
                        Text('UNGGULAN',
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Hapus dari favorit',
                      visualDensity: VisualDensity.compact,
                      constraints:
                          const BoxConstraints.tightFor(width: 32, height: 32),
                      padding: EdgeInsets.zero,
                      onPressed: () => _removeFavorite(title),
                      icon: Icon(Icons.favorite, size: 18, color: tealText),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  '$location • $time',
                  style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
