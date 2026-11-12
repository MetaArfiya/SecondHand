import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'ad_approval_store.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedFilter = 0;

  List<AdListing> _filter(List<AdListing> listings) {
    if (_selectedFilter == 0) {
      return listings
          .where((listing) => listing.status == AdStatus.awaitingApproval)
          .toList();
    }
    if (_selectedFilter == 1) {
      return listings
          .where((listing) => listing.status == AdStatus.approved)
          .toList();
    }
    return listings
        .where((listing) => listing.status == AdStatus.rejected)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('Panel Admin'),
        actions: [
          IconButton(
            tooltip: 'Tutup panel admin',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<AdListing>>(
        valueListenable: AdApprovalStore.listings,
        builder: (context, listings, _) {
          final pendingCount = listings
              .where((item) => item.status == AdStatus.awaitingApproval)
              .length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: _summaryCard(pendingCount),
              ),
              SizedBox(
                height: 48,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterChip('Perlu ditinjau', 0),
                    _filterChip('Disetujui', 1),
                    _filterChip('Ditolak', 2),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _filter(listings).isEmpty
                    ? _emptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: _filter(listings).length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _listingCard(_filter(listings)[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryCard(int pendingCount) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryPurple, AppTheme.secondaryPurple],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.fact_check_outlined,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Konfirmasi iklan',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('$pendingCount iklan menunggu pemeriksaan pembayaran',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _filterChip(String label, int index) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: _selectedFilter == index,
          onSelected: (_) => setState(() => _selectedFilter = index),
        ),
      );

  Widget _listingCard(AdListing listing) => Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (listing.photos.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  listing.photos.first,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 14),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.bgPurpleTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_categoryIcon(listing.category),
                      color: AppTheme.primaryPurple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(listing.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(listing.price,
                          style: const TextStyle(
                              color: AppTheme.primaryPurple,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                _statusBadge(listing.status),
              ],
            ),
            const SizedBox(height: 14),
            _meta(Icons.person_outline, listing.seller),
            const SizedBox(height: 6),
            _meta(Icons.location_on_outlined, listing.location),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  listing.isPaid ? Icons.check_circle : Icons.pending_outlined,
                  size: 16,
                  color: listing.isPaid ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 6),
                Text(
                  listing.isPaid ? 'Pembayaran tercatat' : 'Belum dibayar',
                  style: TextStyle(
                    fontSize: 12,
                    color: listing.isPaid ? Colors.green.shade700 : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showDetails(listing),
                  child: const Text('Detail'),
                ),
              ],
            ),
            if (listing.status == AdStatus.awaitingApproval) ...[
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _reject(listing),
                      child: const Text('Tolak'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: listing.isPaid ? () => _approve(listing) : null,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Setujui iklan'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );

  Widget _meta(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textGrey),
          const SizedBox(width: 6),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: AppTheme.textGrey, fontSize: 12))),
        ],
      );

  Widget _statusBadge(AdStatus status) {
    final label = switch (status) {
      AdStatus.awaitingApproval => 'Menunggu',
      AdStatus.approved => 'Tayang',
      AdStatus.rejected => 'Ditolak',
      AdStatus.sold => 'Terjual',
    };
    final color = switch (status) {
      AdStatus.awaitingApproval => Colors.orange,
      AdStatus.approved => Colors.green,
      AdStatus.rejected => AppTheme.dangerRed,
      AdStatus.sold => Colors.blueGrey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  IconData _categoryIcon(String category) => switch (category) {
        'Mobil' => Icons.directions_car,
        'Motor' => Icons.motorcycle,
        'Sepeda' => Icons.pedal_bike,
        'HP' => Icons.smartphone,
        _ => Icons.inventory_2_outlined,
      };

  Widget _emptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                _selectedFilter == 0
                    ? 'Tidak ada iklan yang menunggu konfirmasi.'
                    : 'Belum ada iklan pada kategori status ini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );

  Future<void> _showDetails(AdListing listing) => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(listing.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${listing.category} • ${listing.location}'),
                const SizedBox(height: 8),
                Text(listing.price,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(listing.description),
                const SizedBox(height: 12),
                Text('Penjual: ${listing.seller}'),
                Text('Pembayaran: ${listing.isPaid ? 'Tercatat' : 'Belum dibayar'}'),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup')),
          ],
        ),
      );

  void _approve(AdListing listing) {
    AdApprovalStore.updateStatus(listing.id, AdStatus.approved);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Iklan ${listing.title} disetujui dan siap tayang.')),
    );
  }

  void _reject(AdListing listing) {
    AdApprovalStore.updateStatus(listing.id, AdStatus.rejected);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Iklan ${listing.title} ditolak.')),
    );
  }
}
