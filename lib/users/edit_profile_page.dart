import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../app_theme.dart';
import '../auth_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.initialUser});

  final LocalUser initialUser;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  final _imagePicker = ImagePicker();
  Uint8List? _avatarBytes;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialUser.name;
    _phoneController.text = widget.initialUser.phone;
    _locationController.text = widget.initialUser.location;
    _bioController.text = widget.initialUser.bio;
    _avatarBytes = widget.initialUser.avatarBytes;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  String get _initials {
    final words = _nameController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2);
    final initials = words.map((word) => word[0]).join().toUpperCase();
    return initials.isEmpty ? 'NA' : initials;
  }

  Future<void> _chooseAvatar() async {
    final options = <({ImageSource source, String label, IconData icon})>[];
    if (_imagePicker.supportsImageSource(ImageSource.gallery)) {
      options.add((
        source: ImageSource.gallery,
        label: 'Pilih dari galeri',
        icon: Icons.photo_library_outlined,
      ));
    }
    if (_imagePicker.supportsImageSource(ImageSource.camera)) {
      options.add((
        source: ImageSource.camera,
        label: 'Ambil foto',
        icon: Icons.photo_camera_outlined,
      ));
    }
    if (options.isEmpty) {
      _showMessage('Pemilih gambar tidak tersedia di perangkat ini.');
      return;
    }

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('Foto profil',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...options.map((option) => ListTile(
                  leading: Icon(option.icon, color: AppTheme.primaryPurple),
                  title: Text(option.label),
                  onTap: () => Navigator.pop(sheetContext, option.source),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (mounted) setState(() => _avatarBytes = bytes);
    } on PlatformException catch (error) {
      _showMessage(error.message ?? 'Foto tidak dapat dipilih.');
    } catch (_) {
      _showMessage('Foto tidak dapat dipilih. Coba lagi.');
    }
  }

  Future<void> _chooseLocation() async {
    const locations = [
      'Jakarta Selatan',
      'Jakarta Pusat',
      'Jakarta Barat',
      'Bandung',
      'Depok',
      'Tangerang',
      'Surabaya',
    ];
    final location = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(
              title: Text('Pilih kota/kecamatan',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...locations.map((item) => ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(item),
                  onTap: () => Navigator.pop(sheetContext, item),
                )),
          ],
        ),
      ),
    );
    if (location != null && mounted) {
      setState(() => _locationController.text = location);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      LocalUser(
        name: _nameController.text.trim(),
        email: widget.initialUser.email,
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        bio: _bioController.text.trim(),
        avatarBytes: _avatarBytes,
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(title: const Text('Edit profil')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              color: AppTheme.bgPurpleTint,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppTheme.accentLavender, width: 2),
                              image: _avatarBytes == null
                                  ? null
                                  : DecorationImage(
                                      image: MemoryImage(_avatarBytes!),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            alignment: Alignment.center,
                            child: _avatarBytes == null
                                ? Text(_initials,
                                    style: const TextStyle(
                                      color: AppTheme.primaryPurple,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ))
                                : null,
                          ),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Material(
                              color: AppTheme.darkPlum,
                              shape: const CircleBorder(),
                              child: IconButton(
                                tooltip: 'Ganti foto profil',
                                onPressed: _chooseAvatar,
                                icon: const Icon(Icons.camera_alt_outlined,
                                    color: Colors.white, size: 18),
                                constraints: const BoxConstraints.tightFor(
                                    width: 38, height: 38),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Nama lengkap *',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Nama lengkap wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(15),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Nomor telepon/WhatsApp *',
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: 'Contoh: 081234567890',
                        helperText:
                            'Nomor ini akan digunakan pembeli untuk menghubungimu lewat WhatsApp.',
                      ),
                      validator: (value) {
                        final phone = value?.trim() ?? '';
                        if (phone.isEmpty) return 'Nomor telepon wajib diisi';
                        if (!RegExp(r'^\d{10,15}$').hasMatch(phone)) {
                          return 'Nomor harus berupa 10 sampai 15 angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      readOnly: true,
                      onTap: _chooseLocation,
                      decoration: const InputDecoration(
                        labelText: 'Lokasi *',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        suffixIcon: Icon(Icons.keyboard_arrow_down),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Pilih lokasi terlebih dahulu'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bioController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      maxLength: 160,
                      decoration: const InputDecoration(
                        labelText: 'Bio/deskripsi singkat (opsional)',
                        prefixIcon: Icon(Icons.notes_outlined),
                        alignLabelWithHint: true,
                        hintText: 'Contoh: Penjual barang bekas berkualitas',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: widget.initialUser.email,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        suffixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _save,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.darkPlum,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
