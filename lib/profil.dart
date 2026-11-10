import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'auth_service.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  // Warna Kustom
  final Color darkBlue = AppTheme.darkPlum;
  final Color limeGreen = AppTheme.accentLavender;
  final Color darkGreen = AppTheme.primaryPurple;
  String _name = LocalAuthService.displayName;
  String _location = 'Jakarta Selatan';
  String _phone = '';
  String _bio = '';
  Uint8List? _avatarBytes;
  bool _transactionNotifications = true;
  bool _promoNotifications = false;
  bool _publicProfile = true;
  bool _allowMessages = true;

  @override
  void initState() {
    super.initState();
    final user = LocalAuthService.currentUser;
    if (user != null) {
      _name = user.name;
      _location = user.location;
      _phone = user.phone;
      _bio = user.bio;
      _avatarBytes = user.avatarBytes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = _name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/logo_secondHand.png',
                        width: 52,
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Profil',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _showEditProfile,
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        color: AppTheme.dangerRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // --- INFO USER ---
              Row(
                children: [
                  // Avatar Inisial
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: AppTheme.bgPurpleTint,
                      shape: BoxShape.circle,
                    ),
                    child: _avatarBytes == null
                        ? Center(
                            child: Text(
                              initials.isEmpty ? 'NA' : initials,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: darkBlue,
                              ),
                            ),
                          )
                        : ClipOval(
                            child: Image.memory(
                              _avatarBytes!,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Detail User
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkBlue,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.verified,
                                color: AppTheme.secondaryPurple, size: 16),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _location,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _phone.isNotEmpty
                              ? _phone
                              : LocalAuthService.currentUser?.email ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_bio.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _bio,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // --- BANNER KEAMANAN (Hijau Gelap) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: darkGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SECONDHAND AMAN',
                      style: TextStyle(
                        color: limeGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Jual beli tanpa rasa ragu.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Selalu cek kondisi barang dan bertemu di tempat ramai.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- MENU LIST ---
              _buildMenuItem(
                icon: Icons.shield_outlined,
                title: 'Pusat bantuan',
                onTap: _showHelpCenter,
              ),
              _buildMenuItem(
                icon: Icons.chat_bubble_outline,
                title: 'Notifikasi',
                onTap: _showNotificationSettings,
              ),
              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Pengaturan akun',
                onTap: _showAccountSettings,
              ),
              _buildMenuItem(
                icon: Icons.login,
                title: 'Masuk atau ganti akun',
                onTap: _openLoginPage,
              ),
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Keluar',
                onTap: _showLogoutConfirmation,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditProfile() async {
    final currentUser = LocalAuthService.currentUser ??
        LocalUser(
          name: _name,
          email: '',
          phone: _phone,
          location: _location,
          bio: _bio,
          avatarBytes: _avatarBytes,
        );
    final updatedUser = await Navigator.push<LocalUser>(
      context,
      MaterialPageRoute<LocalUser>(
        builder: (_) => EditProfilePage(initialUser: currentUser),
      ),
    );
    if (updatedUser == null || !mounted) return;
    LocalAuthService.updateCurrentUserProfile(updatedUser);
    setState(() {
      _name = updatedUser.name;
      _location = updatedUser.location;
      _phone = updatedUser.phone;
      _bio = updatedUser.bio;
      _avatarBytes = updatedUser.avatarBytes;
    });
  }

  void _openLoginPage() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
    );
  }

  Future<void> _showLogoutConfirmation() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu perlu masuk kembali untuk melanjutkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      LocalAuthService.logout();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  Future<void> _showHelpCenter() => showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Pusat bantuan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                ExpansionTile(
                  title: Text('Bagaimana cara menjual barang?'),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                          'Tekan tombol tambah, pilih kategori, lalu lengkapi detail barang.'),
                    ),
                  ],
                ),
                ExpansionTile(
                  title: Text('Bagaimana menjaga transaksi tetap aman?'),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                          'Periksa barang secara langsung dan lakukan pertemuan di tempat umum.'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );

  Future<void> _showNotificationSettings() async {
    var transactionNotifications = _transactionNotifications;
    var promoNotifications = _promoNotifications;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Notifikasi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Aktivitas transaksi'),
                value: transactionNotifications,
                onChanged: (value) =>
                    setDialogState(() => transactionNotifications = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Promo dan rekomendasi'),
                value: promoNotifications,
                onChanged: (value) =>
                    setDialogState(() => promoNotifications = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _transactionNotifications = transactionNotifications;
                  _promoNotifications = promoNotifications;
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAccountSettings() async {
    var publicProfile = _publicProfile;
    var allowMessages = _allowMessages;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Pengaturan akun'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Profil dapat dilihat pengguna lain'),
                value: publicProfile,
                onChanged: (value) =>
                    setDialogState(() => publicProfile = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Izinkan pesan dari pengguna'),
                value: allowMessages,
                onChanged: (value) =>
                    setDialogState(() => allowMessages = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _publicProfile = publicProfile;
                  _allowMessages = allowMessages;
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Menu Item
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            // Ikon dalam lingkaran abu-abu
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: darkBlue, size: 20),
            ),
            const SizedBox(width: 16),
            // Teks Menu
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: darkBlue,
                ),
              ),
            ),
            // Ikon Panah Kanan
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}
