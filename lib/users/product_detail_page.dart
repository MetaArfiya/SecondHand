import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_theme.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavorite,
  });

  final Map<String, Object> product;
  final bool isFavorite;
  final VoidCallback onFavorite;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  String _value(String key) {
    final value = widget.product[key]?.toString();
    if (value != null && value.isNotEmpty) return value;
    return switch (key) {
      'seller' => 'Pengguna SecondHand',
      'condition' => 'Bekas',
      'description' => 'Hubungi penjual untuk informasi lebih lanjut.',
      _ => '',
    };
  }

  Future<void> _contactSeller(BuildContext context) async {
    var phone = _value('phone').replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor WhatsApp penjual belum tersedia.')),
      );
      return;
    }
    if (phone.startsWith('0')) {
      phone = '62${phone.substring(1)}';
    } else if (phone.startsWith('8')) {
      phone = '62$phone';
    }
    final message = Uri.encodeComponent(
      'Halo ${_value('seller')}, saya tertarik dengan ${_value('title')} '
      'seharga ${_value('price')} di SecondHand. Apakah barangnya masih tersedia?',
    );
    final uri = Uri.parse('https://wa.me/$phone?text=$message');
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp tidak dapat dibuka.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _value('title');
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Detail barang', style: TextStyle(fontSize: 17)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip:
                _isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
              widget.onFavorite();
            },
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : AppTheme.darkPlum,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          AspectRatio(
            aspectRatio: 1.15,
            child: widget.product['imageBytes'] is Uint8List
                ? Image.memory(
                    widget.product['imageBytes']! as Uint8List,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    _value('image'),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported_outlined,
                          size: 56),
                    ),
                  ),
          ),
          _section(
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_value('price'), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: AppTheme.darkPlum)),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _tag(_value('condition')),
                _tag(_value('category')),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 17, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(_value('location'), style: TextStyle(color: Colors.grey.shade700)),
                const Spacer(),
                Text(_value('time'), style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ]),
            ]),
          ),
          _section(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Deskripsi barang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(_value('description'), style: TextStyle(height: 1.55, color: Colors.grey.shade800)),
          ])),
          _section(Row(children: [
            CircleAvatar(
              backgroundColor: AppTheme.bgPurpleTint,
              child: Text(_value('seller').isEmpty ? '?' : _value('seller')[0].toUpperCase(), style: const TextStyle(color: AppTheme.darkPlum, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Diiklankan oleh', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 3),
              Text(_value('seller'), style: const TextStyle(fontWeight: FontWeight.w600)),
              if (_value('phone').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('WhatsApp: ${_value('phone')}',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
              ],
            ])),
            Icon(Icons.verified_user_outlined, color: Colors.grey.shade500),
          ])),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x16000000), blurRadius: 10, offset: Offset(0, -3))]),
          child: SizedBox(
            height: 50,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF20A85A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => _contactSeller(context),
              icon: const Icon(Icons.chat_outlined),
              label: const Text('Pesan penjual via WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(Widget child) => Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: child,
      );

  Widget _tag(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: AppTheme.bgPurpleTint, borderRadius: BorderRadius.circular(6)),
        child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.darkPlum, fontWeight: FontWeight.w600)),
      );
}
