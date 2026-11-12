import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../admin/ad_approval_store.dart';
import '../auth_service.dart';
import 'jual_barang.dart'; // Import halaman jual barang
import 'product_detail_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Warna Kustom
  final Color darkBlue = AppTheme.primaryPurple;
  final Color limeGreen = AppTheme.accentLavender;
  final Color tealText = AppTheme.secondaryPurple;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  String _location = 'Jakarta Selatan';
  String _sortOrder = 'Relevan';
  final Set<String> _favoriteTitles = <String>{};
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, Object>> _products = [
    {
      'category': 'Mobil',
      'title': 'Honda HR-V E CVT 2...',
      'price': 'Rp 268.000.000',
      'location': 'JAKARTA SELATAN',
      'time': '12 MENIT',
      'image': 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=400&q=80',
      'featured': true,
    },
    {
      'category': 'Motor',
      'title': 'Vespa Sprint 150 i-Get',
      'price': 'Rp 42.500.000',
      'location': 'BANDUNG',
      'time': '35 MENIT',
      'image': 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=400&q=80',
      'featured': false,
    },
    {
      'category': 'Sepeda',
      'title': 'Polygon Xtrada 5',
      'price': 'Rp 5.850.000',
      'location': 'JAKARTA',
      'time': '1 JAM',
      'image': 'https://images.unsplash.com/photo-1485965120184-e220f721d03e?auto=format&fit=crop&w=400&q=80',
      'featured': false,
    },
    {
      'category': 'HP',
      'title': 'iPhone 13 128GB',
      'price': 'Rp 8.250.000',
      'location': 'DEPOK',
      'time': '2 JAM',
      'image': 'https://images.unsplash.com/photo-1632661674596-df8be070a5c5?auto=format&fit=crop&w=400&q=80',
      'featured': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- BODY ---
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            _buildCategories(),
            const SizedBox(height: 10),
            _buildBanner(),
            const SizedBox(height: 15),
            _buildRecommendationHeader(),
            _buildProductGrid(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET: HEADER (Pencarian & Profil)
  // ==========================================
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: darkBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
      child: Column(
        children: [
          ValueListenableBuilder<LocalUser?>(
            valueListenable: LocalAuthService.userUpdates,
            builder: (context, user, _) => Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: AppTheme.accentLavender,
                  backgroundImage: user?.avatarBytes == null
                      ? null
                      : MemoryImage(user!.avatarBytes!),
                  child: user?.avatarBytes == null
                      ? Text(
                          (user?.name ?? LocalAuthService.displayName)
                                  .trim()
                                  .isEmpty
                              ? 'U'
                              : (user?.name ?? LocalAuthService.displayName)
                                  .trim()[0]
                                  .toUpperCase(),
                          style: const TextStyle(
                              color: AppTheme.darkPlum,
                              fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? LocalAuthService.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      InkWell(
                        onTap: user == null ? _showLocationPicker : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white70, size: 14),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                user?.location ?? _location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: Colors.white70, size: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Notifikasi',
                  constraints:
                      const BoxConstraints.tightFor(width: 40, height: 40),
                  padding: EdgeInsets.zero,
                  onPressed: _showNotifications,
                  icon: Icon(Icons.notifications_none,
                      color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) =>
                        setState(() => _searchQuery = value.trim()),
                    decoration: InputDecoration(
                      hintText: 'Cari barang bekas...',
                      hintStyle:
                          TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon:
                          Icon(Icons.search, color: Colors.grey.shade400),
                      border: InputBorder.none,
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 45,
                width: 45,
                child: Material(
                  color: limeGreen,
                  borderRadius: BorderRadius.circular(8),
                  child: IconButton(
                    tooltip: 'Filter barang',
                    onPressed: _showFilters,
                    icon: Icon(Icons.tune, color: darkBlue),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
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
                onPressed: () => setState(() => _selectedCategory = 'Semua'),
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
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
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
  // WIDGET: BANNER
  // ==========================================
  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryPurple, AppTheme.secondaryPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(Icons.camera_alt,
                  size: 80, color: Colors.white.withValues(alpha: 0.1)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.local_offer, color: Colors.white, size: 10),
                      SizedBox(width: 4),
                      Text('PASANG GRATIS',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Jual barang bekasmu',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Upload gratis, langsung terhubung pembeli.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Tombol banner juga mengarah ke Jual Barang
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const JualBarangPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: limeGreen,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add, size: 16),
                        SizedBox(width: 6),
                        Text('Jual barang sekarang',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET: HEADER REKOMENDASI
  // ==========================================
  Widget _buildRecommendationHeader() {
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
                'REKOMENDASI',
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5),
              ),
              Text(
                _selectedCategory == 'Semua'
                    ? 'Pilihan di sekitarmu'
                    : 'Kategori $_selectedCategory',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          TextButton(
            onPressed: () => setState(() {
              _selectedCategory = 'Semua';
              _searchController.clear();
              _searchQuery = '';
              _sortOrder = 'Relevan';
            }),
            child: Text('Lihat semua', style: TextStyle(color: tealText)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET: GRID PRODUK
  // ==========================================
  Widget _buildProductGrid() {
    return ValueListenableBuilder<List<AdListing>>(
      valueListenable: AdApprovalStore.listings,
      builder: (context, listings, _) {
        final query = _searchQuery.toLowerCase();
        final products = _allProducts(listings).where((product) {
          final matchesCategory = _selectedCategory == 'Semua' ||
              product['category'] == _selectedCategory;
          final searchableText =
              '${product['title']} ${product['category']} ${product['location']}'
                  .toLowerCase();
          return matchesCategory && searchableText.contains(query);
        }).toList();
        if (_sortOrder == 'Harga terendah') {
          products.sort((a, b) =>
              _priceValue(a['price'] as String).compareTo(_priceValue(b['price'] as String)));
        } else if (_sortOrder == 'Harga tertinggi') {
          products.sort((a, b) =>
              _priceValue(b['price'] as String).compareTo(_priceValue(a['price'] as String)));
        }

        if (products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Belum ada barang di kategori ini.')),
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
            children: products.map(_buildProductCard).toList(),
          ),
        );
      },
    );
  }

  List<Map<String, Object>> _allProducts(List<AdListing> listings) {
    final products = List<Map<String, Object>>.from(_products);
    for (final listing in listings.where((item) => item.status == AdStatus.approved)) {
      if (listing.photos.isEmpty) continue;
      products.add({
        'category': listing.category,
        'title': listing.title,
        'price': listing.price,
        'location': listing.location,
        'time': 'BARU',
        'image': '',
        'imageBytes': listing.photos.first,
        'featured': false,
        'condition': 'Bekas',
        'description': listing.description,
        'seller': listing.seller,
        'phone': listing.sellerPhone,
      });
    }
    return products;
  }
  int _priceValue(String price) =>
      int.parse(price.replaceAll(RegExp(r'[^0-9]'), ''));

  void _toggleFavorite(String title) {
    setState(() {
      if (!_favoriteTitles.add(title)) {
        _favoriteTitles.remove(title);
      }
    });
    final isFavorite = _favoriteTitles.contains(title);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isFavorite
            ? '$title ditambahkan ke favorit.'
            : '$title dihapus dari favorit.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showProductDetails(Map<String, Object> product) async {
    final title = product['title']! as String;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(
          product: product,
          isFavorite: _favoriteTitles.contains(title),
          onFavorite: () => _toggleFavorite(title),
        ),
      ),
    );
  }
  Future<void> _showLocationPicker() async {
    const locations = [
      'Jakarta Selatan',
      'Jakarta Pusat',
      'Bandung',
      'Depok',
      'Tangerang',
      'Surabaya',
    ];
    final selectedLocation = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(
              title: Text('Pilih lokasi',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...locations.map((location) => ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(location),
                  trailing: location == _location
                      ? Icon(Icons.check, color: tealText)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, location),
                )),
          ],
        ),
      ),
    );
    if (selectedLocation != null && mounted) {
      setState(() => _location = selectedLocation);
    }
  }

  Future<void> _showNotifications() => showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Notifikasi'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_none, size: 40, color: Colors.grey),
              SizedBox(height: 12),
              Text('Belum ada notifikasi baru.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );

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
                const Text('Filter barang',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  children: [
                    'Relevan',
                    'Harga terendah',
                    'Harga tertinggi',
                  ].map((item) => ChoiceChip(
                    label: Text(item),
                    selected: sortOrder == item,
                    onSelected: (_) => setSheetState(() => sortOrder = item),
                  )).toList(),
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

  Widget _buildProductCard(Map<String, Object> product) {
    final title = product['title']! as String;
    final price = product['price']! as String;
    final location = product['location']! as String;
    final time = product['time']! as String;
    final imageUrl = product['image']! as String;
    final imageBytes = product['imageBytes'];
    final isFeatured = product['featured']! as bool;
    final isFavorite = _favoriteTitles.contains(title);
    return InkWell(
      onTap: () => _showProductDetails(product),
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
                      color: AppTheme.accentLavender,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.star, size: 8, color: AppTheme.darkPlum),
                        SizedBox(width: 2),
                        Text('UNGGULAN',
                            style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkPlum)),
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
                      tooltip: isFavorite
                          ? 'Hapus dari favorit'
                          : 'Tambahkan ke favorit',
                      visualDensity: VisualDensity.compact,
                      constraints:
                          const BoxConstraints.tightFor(width: 32, height: 32),
                      padding: EdgeInsets.zero,
                      onPressed: () => _toggleFavorite(title),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFavorite
                            ? AppTheme.dangerRed
                            : Colors.grey.shade400,
                      ),
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
