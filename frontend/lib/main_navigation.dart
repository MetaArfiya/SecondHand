import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'users/dashboard.dart';
import 'users/favorite.dart';
import 'users/jualanku.dart';
import 'users/profil.dart';
import 'users/jual_barang.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    FavoritePage(),
    JualankuPage(),
    ProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: keyboardVisible
          ? null
          : SafeArea(
              top: false,
              child: Container(
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    _navigationItem(0, Icons.home_outlined, 'Beranda'),
                    _navigationItem(1, Icons.favorite_border, 'Favorit'),
                    SizedBox(
                      width: 64,
                      child: Center(
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: FloatingActionButton(
                            heroTag: 'add_listing_button',
                            onPressed: _openCreateListing,
                            backgroundColor: AppTheme.accentLavender,
                            foregroundColor: AppTheme.darkPlum,
                            elevation: 1,
                            shape: const CircleBorder(),
                            child: const Icon(Icons.add, size: 28),
                          ),
                        ),
                      ),
                    ),
                    _navigationItem(2, Icons.storefront_outlined, 'Jualanku'),
                    _navigationItem(3, Icons.person_outline, 'Profil'),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _navigationItem(int pageIndex, IconData icon, String label) {
    final selected = _currentIndex == pageIndex;
    final color = selected ? AppTheme.secondaryPurple : AppTheme.textLightGrey;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = pageIndex),
        child: SizedBox(
          height: 66,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 23),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCreateListing() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const JualBarangPage()),
    );
  }
}
