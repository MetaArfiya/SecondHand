import 'package:flutter/material.dart';
import 'app_theme.dart';

class DetailIklanPage extends StatefulWidget {
  const DetailIklanPage({super.key});

  @override
  State<DetailIklanPage> createState() => _DetailIklanPageState();
}

class _DetailIklanPageState extends State<DetailIklanPage> {
  // Warna Kustom
  final Color darkBlue = AppTheme.darkPlum;
  final Color darkGreen = AppTheme.primaryPurple;
  final Color limeGreen = AppTheme.accentLavender;
  final Color lightGreenBg = AppTheme.bgPurpleTint;

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

            // --- FORM INPUT ---
            
            // 1. Judul Iklan
            _buildLabel('Judul iklan'),
            _buildTextField(
              hint: 'Contoh: Mobil terawat siap pakai',
            ),
            const SizedBox(height: 20),

            // 2. Harga
            _buildLabel('Harga'),
            _buildTextField(
              hint: 'Rp 0',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // 3. Lokasi
            _buildLabel('Lokasi'),
            _buildTextField(
              hint: 'Pilih kota atau kecamatan',
              suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              readOnly: true, // Biasanya membuka bottom sheet pilihan lokasi
              onTap: () {
                // Logika buka peta / pilihan lokasi
              },
            ),
            const SizedBox(height: 20),

            // 4. Deskripsi
            _buildLabel('Deskripsi'),
            _buildTextField(
              hint: 'Jelaskan kondisi, kelengkapan, dan alasan dijual...',
              maxLines: 5,
            ),
            const SizedBox(height: 25),

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
                      'Upload iklan selalu gratis. Nomor WhatsApp hanya dipakai agar calon pembeli dapat menghubungimu.',
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

            // --- TOMBOL TAYANG GRATIS ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Logika upload data iklan ke backend
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Iklan berhasil ditayangkan!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Tayang gratis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // --- TEKS PROMOSI ---
            Center(
              child: TextButton(
                onPressed: () {
                  // Logika ke halaman promosi berbayar
                },
                child: Text(
                  'Tayang + promosikan iklan',
                  style: TextStyle(
                    color: AppTheme.dangerRed,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      maxLines: maxLines,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
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
