import 'package:flutter/material.dart';

import 'pages/aturan_denda_page.dart';
import 'pages/beranda_penghuni_page.dart';
import 'pages/kelola_kamar_page.dart';
import 'pages/komplain_fasilitas_page.dart';
import 'pages/menu_kelola_page.dart';
import 'pages/papan_pengumuman_page.dart';
import 'pages/laporan_aduan_page.dart';
import 'pages/login_page_v2.dart';
import 'pages/dashboard_pemilik_page.dart';
import 'pages/data_penghuni_page.dart';
import 'pages/login_page.dart';
import 'pages/pembayaran_qris_page.dart';
import 'pages/pembayaran_transfer_page.dart';
import 'pages/register_page.dart';
import 'pages/rincian_tagihan_page.dart';
import 'pages/riwayat_tiket_page.dart';
import 'pages/verifikasi_pembayaran_page.dart';

void main() {
  runApp(const KosAsihApp());
}

class KosAsihApp extends StatelessWidget {
  const KosAsihApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KosAsih',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B87),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const LoginKosAsihPage(),
      routes: <String, WidgetBuilder>{
        LoginKosAsihPage.routeName: (_) => const LoginKosAsihPage(),
        RegisterKosAsihPage.routeName: (_) => const RegisterKosAsihPage(),
        BerandaKosAsihPage.routeName: (_) => const BerandaKosAsihPage(),
        DashboardPemilikPage.routeName: (_) => const DashboardPemilikPage(),
        VerifikasiPembayaranPage.routeName: (_) =>
            const VerifikasiPembayaranPage(),
        KelolaKamarPage.routeName: (_) => const KelolaKamarPage(),
        DataPenghuniPage.routeName: (_) => const DataPenghuniPage(),
        AturanDendaPage.routeName: (_) => const AturanDendaPage(),
        MenuKelolaPage.routeName: (_) => const MenuKelolaPage(),
        KomplainFasilitasPage.routeName: (_) => const KomplainFasilitasPage(),
        PapanPengumumanPage.routeName: (_) => const PapanPengumumanPage(),
        LaporanAduanPage.routeName: (_) => const LaporanAduanPage(),
        RincianTagihanPage.routeName: (_) => const RincianTagihanPage(),
        RiwayatTiketPage.routeName: (_) => const RiwayatTiketPage(),
        PembayaranTransferPage.routeName: (_) =>
            const PembayaranTransferPage(),
        PembayaranQrisPage.routeName: (_) => const PembayaranQrisPage(),
        LoginPage.routeName: (_) => const LoginPage(),
        '/home': (_) => const KosAsihHomePage(),
      },
    );
  }
}

class KosAsihHomePage extends StatelessWidget {
  const KosAsihHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KosAsih'),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Notifikasi',
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Selamat datang di KosAsih',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Kelola indekos lebih mudah, rapi, dan terintegrasi.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.home_work_outlined, size: 42),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan Kos',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Pantau hunian, penghuni, dan keuangan Anda.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Menu utama',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const _FeatureTile(
            icon: Icons.meeting_room_outlined,
            title: 'Data Kamar',
            subtitle: 'Kelola ketersediaan dan detail kamar',
          ),
          const _FeatureTile(
            icon: Icons.people_outline,
            title: 'Data Penghuni',
            subtitle: 'Catat dan pantau informasi penghuni',
          ),
          const _FeatureTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Keuangan',
            subtitle: 'Kelola pembayaran dan laporan keuangan',
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
