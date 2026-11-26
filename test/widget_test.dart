import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kostasih_mobile/main.dart';
import 'package:kostasih_mobile/pages/aturan_denda_page.dart';
import 'package:kostasih_mobile/pages/beranda_penghuni_page.dart';
import 'package:kostasih_mobile/pages/komplain_fasilitas_page.dart';
import 'package:kostasih_mobile/pages/menu_kelola_page.dart';
import 'package:kostasih_mobile/pages/papan_pengumuman_page.dart';
import 'package:kostasih_mobile/pages/pembayaran_qris_page.dart';
import 'package:kostasih_mobile/pages/pembayaran_transfer_page.dart';
import 'package:kostasih_mobile/pages/rincian_tagihan_page.dart';
import 'package:kostasih_mobile/pages/riwayat_tiket_page.dart';
import 'package:kostasih_mobile/pages/laporan_aduan_page.dart';
import 'package:kostasih_mobile/pages/login_page_v2.dart';
import 'package:kostasih_mobile/pages/dashboard_pemilik_page.dart';
import 'package:kostasih_mobile/pages/data_penghuni_page.dart';

void main() {
  testWidgets('menampilkan halaman utama KosAsih', (WidgetTester tester) async {
    await tester.pumpWidget(const KosAsihApp());

    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/home');
    await tester.pumpAndSettle();

    expect(find.text('KosAsih'), findsOneWidget);
    expect(find.text('Selamat datang di KosAsih'), findsOneWidget);
    expect(find.text('Data Kamar'), findsOneWidget);
    expect(find.text('Data Penghuni'), findsOneWidget);
    expect(find.text('Keuangan'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('halaman login bisa dibuka dan pindah ke register', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KosAsihApp());

    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator),
    );
    navigator.pushNamed('/login');
    await tester.pumpAndSettle();

    expect(find.text('MASUK'), findsOneWidget);
    expect(find.text('Daftar Sekarang'), findsOneWidget);

    await tester.tap(find.text('Daftar Sekarang'));
    await tester.pumpAndSettle();

    expect(find.text('Daftar Akun Baru'), findsOneWidget);
    expect(find.text('Daftar Sebagai'), findsOneWidget);
  });

  testWidgets('login mengarah ke dashboard pemilik', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KosAsihApp());
    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/login');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'bagus@email.com');
    await tester.enterText(find.byType(TextField).last, 'password');
    await tester.tap(find.text('MASUK'));
    await tester.pumpAndSettle();

    expect(find.text('Selamat Datang, Bu Asih 👋'), findsOneWidget);
    expect(find.text('Tindakan Mendesak'), findsOneWidget);
  });

  testWidgets('beranda penghuni dan dashboard pemilik bisa dirender', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: BerandaKosAsihPage()));
    expect(find.text('Halo, Bagus Wihandono 👋'), findsOneWidget);
    expect(find.text('Menu Utama Penghuni'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: DashboardPemilikPage()));
    expect(find.text('Selamat Datang, Bu Asih 👋'), findsOneWidget);
    expect(find.text('Tindakan Mendesak'), findsOneWidget);
  });

  testWidgets('data penghuni dan aturan denda bisa dirender', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DataPenghuniPage()));
    expect(find.text('Data Penghuni & Pantauan Tamu'), findsOneWidget);
    expect(find.text('Bagus Wihandono'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: AturanDendaPage()));
    expect(find.text('Aturan dan Tarif Denda'), findsOneWidget);
    expect(find.text('Dimas Anggara'), findsOneWidget);
  });

  testWidgets('menu kelola dan komplain fasilitas bisa dirender', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MenuKelolaPage()));
    expect(find.text('Menu Kelola & Pengaturan Kos'), findsOneWidget);
    expect(find.text('Daftar & Kelola Kamar'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: KomplainFasilitasPage()));
    expect(find.text('Komplain Fasilitas'), findsWidgets);
    expect(find.text('Laporan Kerusakan Masuk'), findsOneWidget);
  });

  testWidgets('papan pengumuman, laporan aduan, dan login v2 bisa dirender', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PapanPengumumanPage()));
    expect(find.text('Papan Pengumuman & Siaran Massal'), findsOneWidget);
    expect(find.text('Daftar Pengumuman Aktif'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: LaporanAduanPage()));
    expect(find.text('Laporan / Aduan'), findsOneWidget);
    expect(find.text('Buat Laporan Baru'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    expect(find.text('Masuk Sebagai'), findsOneWidget);
    expect(find.text('MASUK'), findsOneWidget);
  });

  testWidgets('tagihan, riwayat tiket, dan pembayaran bisa dirender', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RincianTagihanPage()));
    expect(find.text('Rincian Tagihan'), findsOneWidget);
    expect(find.text('Rp 1.290.000'), findsOneWidget);
    expect(find.text('Transfer Bank (BCA)'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: RiwayatTiketPage()));
    expect(find.text('Riwayat & Progres Tiket'), findsOneWidget);
    expect(find.text('AC kurang dingin & menetes'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: PembayaranTransferPage()));
    expect(find.text('TOTAL YANG HARUS DITRANSFER'), findsOneWidget);
    expect(find.text('Transfer ke Rekening BCA'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: PembayaranQrisPage()));
    expect(find.text('PT KOSASIH SEJAHTERA UTAMA'), findsOneWidget);
    expect(find.text('Rp 1.290.000'), findsOneWidget);
  });
}
