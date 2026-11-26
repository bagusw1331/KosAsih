import 'package:flutter/material.dart';

/// Bottom navigation bar bersama untuk seluruh halaman Mode Pemilik KosAsih.
///
/// Urutan tab:
/// 0: Beranda
/// 1: Verifikasi
/// 2: Komplain
/// 3: Pengumuman
/// 4: Kelola
class PemilikBottomNav extends StatelessWidget {
  const PemilikBottomNav({
    super.key,
    required this.currentIndex,
    this.verifikasiBadge = 2,
    this.komplainBadge = 1,
    this.onTap,
  });

  final int currentIndex;
  final int verifikasiBadge;
  final int komplainBadge;
  final ValueChanged<int>? onTap;

  static const List<String> _routes = <String>[
    '/dashboard-pemilik',
    '/verifikasi-pembayaran',
    '/komplain-fasilitas',
    '/papan-pengumuman',
    '/menu-kelola',
  ];

  void _handleTap(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }
    if (index == currentIndex) return;
    Navigator.of(context).pushReplacementNamed(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (int index) => _handleTap(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFF1545C7),
        unselectedItemColor: const Color(0xFF64748B),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: verifikasiBadge > 0,
              backgroundColor: const Color(0xFFEF4444),
              label: Text('$verifikasiBadge'),
              child: const Icon(Icons.verified_user_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: verifikasiBadge > 0,
              backgroundColor: const Color(0xFFEF4444),
              label: Text('$verifikasiBadge'),
              child: const Icon(Icons.verified_user),
            ),
            label: 'Verifikasi',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: komplainBadge > 0,
              backgroundColor: const Color(0xFFEF4444),
              label: Text('$komplainBadge'),
              child: const Icon(Icons.build_circle_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: komplainBadge > 0,
              backgroundColor: const Color(0xFFEF4444),
              label: Text('$komplainBadge'),
              child: const Icon(Icons.build_circle),
            ),
            label: 'Komplain',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign),
            label: 'Pengumuman',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Kelola',
          ),
        ],
      ),
    );
  }
}

/// Bottom navigation bar bersama untuk seluruh halaman Mode Penghuni KosAsih.
///
/// Urutan tab:
/// 0: Beranda
/// 1: Tagihan
/// 2: Aduan
/// 3: Panduan
class PenghuniBottomNav extends StatelessWidget {
  const PenghuniBottomNav({
    super.key,
    required this.currentIndex,
    this.allowReselectCurrent = false,
    this.onTap,
  });

  final int currentIndex;
  final bool allowReselectCurrent;
  final ValueChanged<int>? onTap;

  static const List<String?> _routes = <String?>[
    '/beranda-penghuni',
    '/rincian-tagihan',
    '/laporan-aduan',
    null,
  ];

  void _handleTap(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }
    if (index == currentIndex && !allowReselectCurrent) return;
    final String? route = _routes[index];
    if (route == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Halaman Panduan belum tersedia.')),
      );
      return;
    }
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (int index) => _handleTap(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFF1545C7),
        unselectedItemColor: const Color(0xFF64748B),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Tagihan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handyman_outlined),
            activeIcon: Icon(Icons.handyman),
            label: 'Aduan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Panduan',
          ),
        ],
      ),
    );
  }
}
