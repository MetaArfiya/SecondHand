import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import '../app_theme.dart';
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
  final List<Uint8List> _photos = [];
  bool _isPickingPhotos = false;

  Future<void> _choosePhotoSource() async {
    if (_photos.length >= 10 || _isPickingPhotos) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari galeri'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil foto sekarang'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source != null && mounted) await _pickPhotos(source);
  }

  Future<void> _pickPhotos(ImageSource source) async {
    if (_photos.length >= 10 || _isPickingPhotos) return;
    setState(() => _isPickingPhotos = true);
    try {
      final picker = ImagePicker();
      final List<XFile> selected;
      if (source == ImageSource.gallery) {
        selected = await picker.pickMultiImage(
          limit: 10 - _photos.length,
          imageQuality: 85,
        );
      } else {
        final photo = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          maxWidth: 1600,
          maxHeight: 1600,
        );
        selected = photo == null ? <XFile>[] : <XFile>[photo];
      }
      final bytes = <Uint8List>[];
      for (final photo in selected) {
        bytes.add(await photo.readAsBytes());
      }
      if (!mounted) return;
      setState(() => _photos.addAll(bytes));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto tidak dapat dipilih. Coba lagi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingPhotos = false);
    }
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
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...List.generate(_photos.length, (index) => _photoTile(index)),
                if (_photos.length < 10) _addPhotoTile(),
              ],
            ),
            const SizedBox(height: 8),
            Text('${_photos.length}/10 foto dipilih',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
                  if (_photos.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tambahkan minimal satu foto barang.')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailIklanPage(
                        category: _selectedCategory,
                        photos: List.unmodifiable(_photos),
                      ),
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

  Widget _addPhotoTile() => GestureDetector(
        onTap: _choosePhotoSource,
        child: Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isPickingPhotos
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.add_a_photo_outlined,
                      size: 26, color: Colors.grey.shade700),
              const SizedBox(height: 6),
              Text(_isPickingPhotos ? 'Memuat...' : 'Tambah foto',
                  style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      );

  Widget _photoTile(int index) => Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              _photos[index],
              width: 104,
              height: 104,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: () => setState(() => _photos.removeAt(index)),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
          if (index == 0)
            Positioned(
              left: 5,
              bottom: 5,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                    color: AppTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(5)),
                child: const Text('Utama',
                    style: TextStyle(color: Colors.white, fontSize: 9)),
              ),
            ),
        ],
      );

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
