import 'package:flutter/material.dart';

import '../admin/ad_approval_store.dart';
import '../app_theme.dart';
import '../auth_service.dart';
import 'jual_barang.dart';

class JualankuPage extends StatelessWidget {
  const JualankuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sellerEmail = LocalAuthService.currentUser?.email;
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: ValueListenableBuilder<List<AdListing>>(
          valueListenable: AdApprovalStore.listings,
          builder: (context, listings, _) {
            final myListings = listings
                .where((listing) => listing.sellerEmail == sellerEmail)
                .toList();
            final activeCount = myListings
                .where((item) => item.status == AdStatus.approved)
                .length;
            final pendingCount = myListings
                .where((item) => item.status == AdStatus.awaitingApproval)
                .length;
            final soldCount = myListings
                .where((item) => item.status == AdStatus.sold)
                .length;

            return ListView(
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
                    _statCard('$activeCount', 'AKTIF', Colors.green),
                    const SizedBox(width: 10),
                    _statCard('$pendingCount', 'DITINJAU', Colors.orange),
                    const SizedBox(width: 10),
                    _statCard('$soldCount', 'TERJUAL', AppTheme.secondaryPurple),
                  ],
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    const Expanded(
                      child: Text('Iklan saya',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                    ),
                    Text('${myListings.length} iklan',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 14),
                if (myListings.isEmpty)
                  _emptyState()
                else
                  ...myListings.map((listing) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _listingCard(context, listing),
                      )),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => _openCreateListing(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah barang baru'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.darkPlum,
                      side: const BorderSide(color: AppTheme.primaryPurple),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) => Expanded(
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
              Text(value,
                  style: TextStyle(
                      fontSize: 21, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600)),
            ],
          ),
        ),
      );

  Widget _listingCard(BuildContext context, AdListing listing) => Container(
        padding: const EdgeInsets.all(12),
        decoration: AppTheme.cardDecoration,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: listing.photos.isEmpty
                  ? Container(
                      width: 82,
                      height: 82,
                      color: AppTheme.bgPurpleTint,
                      child: const Icon(Icons.inventory_2_outlined,
                          color: AppTheme.primaryPurple),
                    )
                  : Image.memory(
                      listing.photos.first,
                      width: 82,
                      height: 82,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 5),
                  Text(listing.price,
                      style: const TextStyle(
                          color: AppTheme.primaryPurple,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 7),
                  _statusLabel(listing.status),
                  const SizedBox(height: 6),
                  Text(listing.location,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Aksi iklan',
              onSelected: (action) {
                if (action == 'sold') {
                  _confirmMarkSold(context, listing);
                } else if (action == 'delete') {
                  _confirmDelete(context, listing);
                }
              },
              itemBuilder: (context) => [
                if (listing.status == AdStatus.approved)
                  const PopupMenuItem(
                    value: 'sold',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline),
                        SizedBox(width: 10),
                        Text('Tandai terjual'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Hapus barang'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _statusLabel(AdStatus status) {
    final (label, color) = switch (status) {
      AdStatus.awaitingApproval => ('Menunggu persetujuan admin', Colors.orange),
      AdStatus.approved => ('Aktif dan tayang', Colors.green),
      AdStatus.rejected => ('Ditolak admin', AppTheme.dangerRed),
      AdStatus.sold => ('Terjual', AppTheme.secondaryPurple),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 10)),
    );
  }

  Widget _emptyState() => Container(
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.cardDecoration,
        child: Column(
          children: [
            Icon(Icons.sell_outlined, size: 42, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            const Text('Belum ada iklan',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text('Barang yang kamu ajukan akan muncul di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      );

  void _openCreateListing(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const JualBarangPage()),
    );
  }

  Future<void> _confirmMarkSold(
      BuildContext context, AdListing listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tandai barang terjual?'),
        content: Text(
            '${listing.title} akan dihapus dari Beranda dan ditandai sebagai terjual.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, sudah terjual'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      AdApprovalStore.updateStatus(listing.id, AdStatus.sold);
    }
  }

  Future<void> _confirmDelete(BuildContext context, AdListing listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus iklan?'),
        content: Text('Iklan ${listing.title} akan dihapus dari Jualanku.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) AdApprovalStore.remove(listing.id);
  }
}
