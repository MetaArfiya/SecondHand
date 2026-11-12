import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

import '../app_theme.dart';
import '../admin/ad_approval_store.dart';
import '../auth_service.dart';

class DetailIklanPage extends StatefulWidget {
  const DetailIklanPage({
    super.key,
    required this.category,
    required this.photos,
  });

  final String category;
  final List<Uint8List> photos;

  @override
  State<DetailIklanPage> createState() => _DetailIklanPageState();
}

class _DetailIklanPageState extends State<DetailIklanPage> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  // Warna Kustom
  final Color darkBlue = AppTheme.darkPlum;
  final Color darkGreen = AppTheme.primaryPurple;
  final Color limeGreen = AppTheme.accentLavender;
  final Color lightGreenBg = AppTheme.bgPurpleTint;

  @override
  void initState() {
    super.initState();
    _locationController.text =
        LocalAuthService.currentUser?.location ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatPrice(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final formatted = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return 'Rp $formatted';
  }

  Future<void> _submitListing({required bool promote}) async {
    if (_titleController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua detail iklan terlebih dahulu.')),
      );
      return;
    }
    final sellerPhone = LocalAuthService.currentUser?.phone.trim() ?? '';
    if (sellerPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tambahkan nomor WhatsApp di Edit Profil sebelum memasang barang.'),
        ),
      );
      return;
    }
    if (promote) {
      final paid = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Promosikan iklan'),
          content: const Text(
              'Biaya promosi Rp 10.000. Setelah pembayaran, promosi akan ditinjau admin.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Nanti saja'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Bayar Rp 10.000'),
            ),
          ],
        ),
      );
      if (paid != true || !mounted) return;
    }

    final user = LocalAuthService.currentUser;
    AdApprovalStore.submit(
      AdListing(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        category: widget.category,
        price: _formatPrice(_priceController.text),
        location: _locationController.text.trim(),
        seller: user?.name ?? LocalAuthService.displayName,
        description: _descriptionController.text.trim(),
        isPaid: promote,
        createdAt: DateTime.now(),
        photos: widget.photos,
        sellerEmail: user?.email ?? '',
        sellerPhone: sellerPhone,
        status: promote ? AdStatus.awaitingApproval : AdStatus.approved,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(promote
            ? 'Promosi diajukan. Admin akan meninjau pembayaran.'
            : 'Barang berhasil dipasang dan sudah tampil di Beranda.'),
      ),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Detail iklan',
              style: TextStyle(
                color: darkBlue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'LANGKAH 2 DARI 2',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: darkBlue),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- JUDUL HALAMAN ---
            Text(
              'Ceritakan barangmu',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Lengkapi detail agar pembeli makin yakin.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 25),

            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    widget.photos[index],
                    width: 140,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- FORM INPUT ---
            
            // 1. Judul Iklan
            _buildLabel('Judul iklan'),
            _buildTextField(
              hint: 'Contoh: Mobil terawat siap pakai',
              controller: _titleController,
            ),
            const SizedBox(height: 20),

            // 2. Harga
            _buildLabel('Harga'),
            _buildTextField(
              hint: '0',
              prefixText: 'Rp ',
              keyboardType: TextInputType.number,
              inputFormatters: [RupiahInputFormatter()],
              controller: _priceController,
            ),
            const SizedBox(height: 20),

            // 3. Lokasi
            _buildLabel('Lokasi'),
            _buildTextField(
              hint: 'Kecamatan, kota/kabupaten, provinsi',
              helperText: 'Tulis lokasi barang selengkap mungkin.',
              controller: _locationController,
            ),
            const SizedBox(height: 20),

            // 4. Deskripsi
            _buildLabel('Deskripsi'),
            _buildTextField(
              hint: 'Jelaskan kondisi, kelengkapan, dan alasan dijual...',
              maxLines: 5,
              controller: _descriptionController,
            ),
            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.bgPurpleTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat_outlined, color: AppTheme.primaryPurple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nomor WhatsApp penjual',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 3),
                        Text(
                          LocalAuthService.currentUser?.phone.isNotEmpty == true
                              ? LocalAuthService.currentUser!.phone
                              : 'Tambahkan nomor di halaman Profil',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- INFO BOX (Hijau Muda) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightGreenBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.verified_user_outlined, color: darkGreen, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pasang barang gratis. Kamu bisa memilih promosi berbayar agar barang lebih mudah ditemukan.',
                      style: TextStyle(
                        fontSize: 11,
                        color: darkGreen,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- PASANG GRATIS / PROMOSIKAN ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _submitListing(promote: false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Pasang gratis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _submitListing(promote: true),
                icon: const Icon(Icons.campaign_outlined),
                label: const Text('Promosikan • Rp 10.000'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET HELPER: Label Form
  // ==========================================
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkBlue,
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET HELPER: Input TextField
  // ==========================================
  Widget _buildTextField({
    required String hint,
    TextEditingController? controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? prefixText,
    String? helperText,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        prefixText: prefixText,
        helperText: helperText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: darkBlue, width: 1.5),
        ),
      ),
    );
  }
}

class RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final rawDigits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final digits = rawDigits.length > 15 ? rawDigits.substring(0, 15) : rawDigits;
    final rawCursor = newValue.selection.extentOffset;
    final cursorOffset = rawCursor < 0
        ? newValue.text.length
        : rawCursor.clamp(0, newValue.text.length).toInt();
    final digitsBeforeCursor =
        newValue.text.substring(0, cursorOffset).replaceAll(RegExp(r'\D'), '');
    final cursorDigits =
        digitsBeforeCursor.length.clamp(0, digits.length).toInt();
    final formatted = _addThousandsSeparators(digits);
    final formattedCursor =
        _addThousandsSeparators(digits.substring(0, cursorDigits)).length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formattedCursor),
      composing: TextRange.empty,
    );
  }

  String _addThousandsSeparators(String digits) => digits.replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
      );
}
