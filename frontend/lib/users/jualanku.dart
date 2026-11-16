import 'dart:async';

import 'package:flutter/material.dart';

import '../api_service.dart';
import '../app_theme.dart';
import 'jual_barang.dart';

class JualankuPage extends StatefulWidget {
  const JualankuPage({super.key});

  @override
  State<JualankuPage> createState() => _JualankuPageState();
}

class _JualankuPageState extends State<JualankuPage>
    with WidgetsBindingObserver {
  late Future<List<Map<String, dynamic>>> _products;
  Timer? _refreshTimer;
  bool _appIsResumed = true;
  bool _refreshInFlight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ApiService.productsChanged.addListener(_refreshOnChange);
    _products = ApiService.products(mine: true);
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_appIsResumed) _refresh();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appIsResumed = state == AppLifecycleState.resumed;
    if (_appIsResumed) _refresh();
  }

  void _refreshOnChange() {
    if (mounted) _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ApiService.productsChanged.removeListener(_refreshOnChange);
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_refreshInFlight) return;
    _refreshInFlight = true;
    final next = ApiService.products(mine: true);
    setState(() {
      _products = next;
    });
    try {
      await next;
    } catch (_) {
      // FutureBuilder displays the request error and provides a retry action.
    } finally {
      _refreshInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgLight,
    body: SafeArea(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ApiService.humanizeError(snapshot.error!),
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: _refresh,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }
          final products = snapshot.data ?? [];
          final active = products
              .where((item) => item['status'] == 'active')
              .length;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                Text(
                  'DASHBOARD PENJUAL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Jualanku', style: AppTheme.heading1),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _stat('$active', 'AKTIF', Colors.green),
                    const SizedBox(width: 10),
                    _stat(
                      '${products.length - active}',
                      'LAINNYA',
                      Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    _stat(
                      '${products.length}',
                      'TOTAL',
                      AppTheme.secondaryPurple,
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Iklan saya',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${products.length} iklan',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (products.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.cardDecoration,
                    child: const Text(
                      'Belum ada iklan. Barang yang kamu pasang akan muncul di sini.',
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ...products.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _productCard(item),
                    ),
                  ),
                SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _openCreateListing,
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah barang baru'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );

  Widget _stat(String value, String label, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _productCard(Map<String, dynamic> product) {
    final images = product['images'] as List? ?? [];
    final image = images.isEmpty
        ? ''
        : (images.first as Map)['url']?.toString() ?? '';
    final double priceNum = double.tryParse(product['price'].toString()) ?? 0;
    final amount = priceNum.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    final isActive = product['status'] == 'active';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: image.isEmpty
                ? Container(
                    width: 82,
                    height: 82,
                    color: AppTheme.bgPurpleTint,
                    child: const Icon(Icons.inventory_2_outlined),
                  )
                : Image.network(
                    ApiService.imageUrl(image),
                    width: 82,
                    height: 82,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 82,
                      height: 82,
                      color: AppTheme.bgPurpleTint,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['title'].toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Rp $amount',
                  style: const TextStyle(
                    color: AppTheme.primaryPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  isActive
                      ? 'Aktif dan tayang'
                      : (product['status'] ?? 'unknown').toString(),
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  (product['location'] ?? '').toString(),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openCreateListing() => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (_) => const JualBarangPage()),
  ).then((_) => _refresh());
}
