import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../admin/ad_approval_store.dart';
import '../auth_service.dart';
import '../api_service.dart';
import 'favorite_store.dart';
import 'jual_barang.dart';
import 'product_detail_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with WidgetsBindingObserver {
  final Color darkBlue = AppTheme.primaryPurple;
  final Color limeGreen = AppTheme.accentLavender;
  final Color tealText = AppTheme.secondaryPurple;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  String _location = 'Jakarta Selatan';
  String _sortOrder = 'Relevan';
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, Object>> _serverProducts = [];
  bool _loadingProducts = true;
  bool _requestInFlight = false;
  bool _appIsResumed = true;
  String? _loadError;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ApiService.productsChanged.addListener(_refreshProducts);
    _loadProducts();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_appIsResumed) _loadProducts();
    });
  }

  void _refreshProducts() => _loadProducts();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appIsResumed = state == AppLifecycleState.resumed;
    if (_appIsResumed) _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (_requestInFlight) return;
    _requestInFlight = true;
    try {
      final categories = await ApiService.categories();
      final names = {
        for (final category in categories) category['id']: category['name'],
      };
      final products = await ApiService.products();
      final favorites = await ApiService.favorites();
      final mapped = products.map<Map<String, Object>>((item) {
        final images = item['images'] as List? ?? [];
        final rawImage = images.isEmpty
            ? ''
            : (images.first as Map)['url']?.toString() ?? '';
        final price = (item['price'] as num).round();
        final formatted = price.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (_) => '.',
        );
        return {
          'id': item['id'] as int,
          'category': names[item['category_id']]?.toString() ?? 'Lainnya',
          'title': item['title'].toString(),
          'price': 'Rp $formatted',
          'location': (item['location'] ?? '').toString().toUpperCase(),
          'time': 'BARU',
          'image': rawImage.isEmpty ? '' : ApiService.imageUrl(rawImage),
          'gallery': images
              .map(
                (image) =>
                    ApiService.imageUrl((image as Map)['url'].toString()),
              )
              .toList(),
          'featured': item['is_promoted'] == true,
          'condition': 'Bekas',
          'description': (item['description'] ?? '').toString(),
          'seller': (item['seller_name'] ?? 'Pengguna SecondHand').toString(),
          'phone': (item['seller_phone'] ?? '').toString(),
        };
      }).toList();
      if (!mounted) return;
      FavoriteStore.items.value = favorites;
      setState(() {
        _serverProducts = mapped;
        _loadingProducts = false;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingProducts = false;
        _loadError = ApiService.humanizeError(error);
      });
    } finally {
      _requestInFlight = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ApiService.productsChanged.removeListener(_refreshProducts);
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
      ),
    );
  }

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
                  backgroundImage: user?.avatarBytes != null
                      ? MemoryImage(user!.avatarBytes!)
                      : user?.avatarUrl != null
                      ? NetworkImage(ApiService.imageUrl(user!.avatarUrl!))
                      : null,
                  child: user?.avatarBytes == null && user?.avatarUrl == null
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
                            fontWeight: FontWeight.bold,
                          ),
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
                            const Icon(
                              Icons.location_on,
                              color: Colors.white70,
                              size: 14,
                            ),
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
                            const Icon(
                              Icons.chevron_right,
                              color: Colors.white70,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Notifikasi',
                  constraints: const BoxConstraints.tightFor(
                    width: 40,
                    height: 40,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: _showNotifications,
                  icon: Icon(
                    Icons.notifications_none,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
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
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade400,
                      ),
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
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.w500,
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
              child: Icon(
                Icons.camera_alt,
                size: 80,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.local_offer, color: Colors.white, size: 10),
                      SizedBox(width: 4),
                      Text(
                        'PASANG GRATIS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Jual barang bekasmu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JualBarangPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: limeGreen,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Jual barang sekarang',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
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
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                _selectedCategory == 'Semua'
                    ? 'Pilihan di sekitarmu'
                    : 'Kategori $_selectedCategory',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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

  Widget _buildProductGrid() {
    return ValueListenableBuilder<List<AdListing>>(
      valueListenable: AdApprovalStore.listings,
      builder: (context, listings, _) {
        final query = _searchQuery.toLowerCase();
        final products = _allProducts(listings).where((product) {
          final matchesCategory =
              _selectedCategory == 'Semua' ||
              product['category'] == _selectedCategory;
          final searchableText =
              '${product['title']} ${product['category']} ${product['location']}'
                  .toLowerCase();
          return matchesCategory && searchableText.contains(query);
        }).toList();
        if (_sortOrder == 'Harga terendah') {
          products.sort(
            (a, b) => _priceValue(
              a['price'] as String,
            ).compareTo(_priceValue(b['price'] as String)),
          );
        } else if (_sortOrder == 'Harga tertinggi') {
          products.sort(
            (a, b) => _priceValue(
              b['price'] as String,
            ).compareTo(_priceValue(a['price'] as String)),
          );
        }

        if (_loadingProducts) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (_loadError != null) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_loadError!, textAlign: TextAlign.center),
                  TextButton(
                    onPressed: _loadProducts,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          );
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
    final products = List<Map<String, Object>>.from(_serverProducts);
    for (final listing in listings.where(
      (item) => item.status == AdStatus.approved,
    )) {
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

  Future<void> _toggleFavorite(
    Map<String, Object> product, {
    bool? favorite,
  }) async {
    final title = product['title']! as String;
    final wasFavorite = FavoriteStore.contains(title);
    final id = product['id'];
    if (id is! int) return;
    try {
      await ApiService.setFavorite(id, favorite ?? !wasFavorite);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ApiService.humanizeError(error)),
        ),
      );
      return;
    }
    FavoriteStore.toggle(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasFavorite
              ? '$title dihapus dari favorit.'
              : '$title ditambahkan ke favorit.',
        ),
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
          isFavorite: FavoriteStore.contains(title),
          onFavorite: (favorite) =>
              _toggleFavorite(product, favorite: favorite),
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
              title: Text(
                'Pilih lokasi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...locations.map(
              (location) => ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: Text(location),
                trailing: location == _location
                    ? Icon(Icons.check, color: tealText)
                    : null,
                onTap: () => Navigator.pop(sheetContext, location),
              ),
            ),
          ],
        ),
      ),
    );
    if (selectedLocation != null && mounted) {
      setState(() => _location = selectedLocation);
    }
  }

  Future<void> _showNotifications() async {
    try {
      final notifications = await ApiService.notifications();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Notifikasi'),
          content: SizedBox(
            width: 420,
            child: notifications.isEmpty
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 40,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text('Belum ada notifikasi.'),
                    ],
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item['title']?.toString() ?? 'Notifikasi'),
                        subtitle: Text(item['body']?.toString() ?? ''),
                        leading: Icon(
                          item['is_read'] == true
                              ? Icons.notifications_none
                              : Icons.notifications_active_outlined,
                        ),
                        onTap: item['is_read'] == true
                            ? null
                            : () async {
                                await ApiService.markNotificationRead(
                                  item['id'] as int,
                                );
                                if (dialogContext.mounted)
                                  Navigator.pop(dialogContext);
                                if (mounted) _showNotifications();
                              },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ApiService.humanizeError(error)),
          ),
        );
    }
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
                const Text(
                  'Filter barang',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Kategori'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Semua', 'Mobil', 'Motor', 'Sepeda', 'HP']
                      .map(
                        (item) => ChoiceChip(
                          label: Text(item),
                          selected: category == item,
                          onSelected: (_) =>
                              setSheetState(() => category = item),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                const Text('Urutkan harga'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Relevan', 'Harga terendah', 'Harga tertinggi']
                      .map(
                        (item) => ChoiceChip(
                          label: Text(item),
                          selected: sortOrder == item,
                          onSelected: (_) =>
                              setSheetState(() => sortOrder = item),
                        ),
                      )
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

  Widget _buildProductCard(Map<String, Object> product) {
    final title = product['title']! as String;
    final price = product['price']! as String;
    final location = product['location']! as String;
    final time = product['time']! as String;
    final imageUrl = product['image']! as String;
    final imageBytes = product['imageBytes'];
    final isFeatured = product['featured']! as bool;
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
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
                          // --- PERBAIKAN DI SINI ---
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 120,
                                width: double.infinity, // Agar gambar full
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 40, // Ikon diperbesar
                                ),
                              ),
                        ),
                ),
                if (isFeatured)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentLavender,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.star, size: 8, color: AppTheme.darkPlum),
                          SizedBox(width: 2),
                          Text(
                            'UNGGULAN',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkPlum,
                            ),
                          ),
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
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      ValueListenableBuilder<List<Map<String, Object>>>(
                        valueListenable: FavoriteStore.items,
                        builder: (context, favorites, _) {
                          final isFavorite = favorites.any(
                            (item) => item['title'] == title,
                          );
                          return IconButton(
                            tooltip: isFavorite
                                ? 'Hapus dari favorit'
                                : 'Tambahkan ke favorit',
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints.tightFor(
                              width: 32,
                              height: 32,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: () => _toggleFavorite(product),
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 18,
                              color: isFavorite
                                  ? AppTheme.dangerRed
                                  : Colors.grey.shade400,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$location • $time',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
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
