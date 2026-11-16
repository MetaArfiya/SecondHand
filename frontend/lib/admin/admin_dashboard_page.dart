import 'package:flutter/material.dart';

import '../api_service.dart';
import '../app_theme.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late Future<List<Map<String, dynamic>>> _payments;
  String _filter = 'waiting_confirmation';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _payments = ApiService.adminPayments(status: _filter);

  String _humanError(Object error) => ApiService.humanizeError(error);

  Future<void> _refresh() async {
    final next = ApiService.adminPayments(status: _filter);
    setState(() => _payments = next);
    await next;
  }

  Future<void> _decide(int id, String status) async {
    try {
      await ApiService.decidePayment(id, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'approved'
                ? 'Pembayaran disetujui.'
                : 'Pembayaran ditolak.',
          ),
        ),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_humanError(error))));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bgLight,
    appBar: AppBar(
      title: const Text('Pembayaran promosi'),
      actions: [
        IconButton(
          tooltip: 'Tutup panel admin',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'waiting_confirmation',
                label: Text('Menunggu'),
              ),
              ButtonSegment(value: 'approved', label: Text('Disetujui')),
              ButtonSegment(value: 'rejected', label: Text('Ditolak')),
            ],
            selected: {_filter},
            onSelectionChanged: (selection) => setState(() {
              _filter = selection.first;
              _load();
            }),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _payments,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError)
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _humanError(snapshot.error!),
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: _refresh,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              final items = snapshot.data ?? [];
              if (items.isEmpty)
                return const Center(
                  child: Text('Belum ada pembayaran pada status ini.'),
                );
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _paymentCard(items[index]),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );

  Widget _paymentCard(Map<String, dynamic> payment) {
    final status = payment['status'].toString();
    final proof = payment['proof_url']?.toString();
    final rawAmount = num.tryParse(payment['total_amount'].toString()) ?? 0;
    final amount = rawAmount.round().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pembayaran #${payment['id']} · Produk #${payment['product_id']}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Total transfer Rp $amount',
            style: const TextStyle(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text('Status: $status'),
          if (proof != null && proof.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                ApiService.imageUrl(proof),
                height: 200,
                width: double.infinity,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Text(
                  'Foto bukti transfer gagal dimuat. Periksa koneksi lalu coba lagi.',
                ),
              ),
            ),
          ],
          if (status == 'waiting_confirmation') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _decide(payment['id'] as int, 'rejected'),
                    child: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _decide(payment['id'] as int, 'approved'),
                    child: const Text('Setujui'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
