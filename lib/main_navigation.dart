import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'dashboard.dart';
import 'favorite.dart';
import 'jualanku.dart';
import 'profil.dart';
import 'jual_barang.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Indeks di navbar menyisakan posisi tengah untuk tombol tambah.
  int get _selectedNavIndex => _currentIndex < 2 ? _currentIndex : _currentIndex + 1;

  final List<Widget> _pages = [
    const DashboardPage(),
    const FavoritePage(),
    const JualankuPage(),
    const ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const JualBarangPage(),
            ),
          );
        },
        backgroundColor: AppTheme.accentLavender,
        foregroundColor: AppTheme.darkPlum,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          if (index == 2) return; // Tombol tambah ditangani oleh FAB.
          final pageIndex = index < 2 ? index : index - 1;
          setState(() => _currentIndex = pageIndex);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.secondaryPurple,
        unselectedItemColor: AppTheme.textLightGrey,
        showUnselectedLabels: true,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorit'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 0), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Jualanku'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
