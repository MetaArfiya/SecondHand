import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'detail_iklan.dart'; // <-- 1. Tambahkan import ini

class JualBarangPage extends StatefulWidget {
  const JualBarangPage({super.key});

  @override
  State<JualBarangPage> createState() => _JualBarangPageState();
}

class _JualBarangPageState extends State<JualBarangPage> {
  // Warna Kustom
  final Color darkGreen = AppTheme.darkPlum;
  final Color limeBg = AppTheme.bgPurpleTint;
  final Color darkBlue = AppTheme.darkPlum;

  // State untuk kategori terpilih (Default: Mobil)
  String _selectedCategory = 'Mobil';

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
            const Text(
              'Jual barang',
              style: TextStyle(
                color: AppTheme.darkPlum,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'LANGKAH 1 DARI 2',
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
            icon: const Icon(Icons.close, color: AppTheme.darkPlum),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- JUDUL ---
            Text(
              'Mulai dari fotonya',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Foto yang jelas bikin barangmu lebih cepat laku.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 25),

            // --- AREA UPLOAD FOTO ---
            Row(
              children: [
                // Kotak Utama (Dashed Border)
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      // Logika tambah foto
                    },
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 1.5,
                          // Catatan: Untuk dashed border sempurna, butuh package seperti dotted_border.
                          // Di sini kita gunakan solid border agar tetap berjalan tanpa dependency.
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              size: 32, color: Colors.grey.shade700),
                          const SizedBox(height: 10),
                          Text(
                            'Tambah foto',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Maks. 10 foto',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Kotak Tambahan (Kanan)
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Center(
                      child: Icon(Icons.add, color: Colors.grey.shade400, size: 30),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- PILIH KATEGORI ---
            Text(
              'Pilih kategori',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 15),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3.2, // Menyesuaikan bentuk kotak kategori
              children: [
                _buildCategoryItem('Mobil', Icons.directions_car),
                _buildCategoryItem('Motor', Icons.motorcycle),
                _buildCategoryItem('Sepeda', Icons.pedal_bike),
                _buildCategoryItem('HP', Icons.smartphone),
              ],
            ),
            const SizedBox(height: 40),

            // --- TOMBOL LANJUTKAN ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // 2. Ubah onPressed untuk navigasi ke DetailIklanPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DetailIklanPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Lanjutkan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET KATEGORI CUSTOM ---
  Widget _buildCategoryItem(String title, IconData icon) {
    bool isSelected = _selectedCategory == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = title;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? limeBg : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.secondaryPurple : AppTheme.borderGrey,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // Ikon dalam kotak abu-abu
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.6)
                    : AppTheme.bgLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 18,
                color: darkBlue,
              ),
            ),
            const SizedBox(width: 10),
            // Teks Kategori
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: darkBlue,
                ),
              ),
            ),
            // Ikon Centang (Hanya muncul jika dipilih)
            if (isSelected)
              Icon(Icons.check, size: 16, color: darkBlue),
          ],
        ),
      ),
    );
  }
}
