import 'dart:io';

<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/komplain_model.dart';
import '../logic/payment_verify_bloc/payment_verify_bloc.dart';
import '../logic/payment_verify_bloc/payment_verify_state.dart';
import '../logic/ticket_fcm_bloc/ticket_fcm_bloc.dart';
import '../logic/ticket_fcm_bloc/ticket_fcm_event.dart';
import '../logic/ticket_fcm_bloc/ticket_fcm_state.dart';
import 'dashboard_pemilik_page.dart';
import 'menu_kelola_page.dart';
import 'papan_pengumuman_page.dart';
import 'verifikasi_pembayaran_page.dart';
=======
import '../widgets/kosasih_bottom_nav.dart';
>>>>>>> 3794f9c95113a0379f74cdcbede3f9935190c627

class KomplainFasilitasPage extends StatefulWidget {
  const KomplainFasilitasPage({super.key});

  /// Nama route, dipakai oleh `main.dart`.
  static const String routeName = '/komplain-fasilitas';

  @override
<<<<<<< HEAD
  State<KomplainFasilitasPage> createState() => _KomplainFasilitasPageState();
}

class _KomplainFasilitasPageState extends State<KomplainFasilitasPage> {
  int _filterIndex =
      0; // 0 = Perlu Ditinjau, 1 = Sedang Diperbaiki, 2 = Selesai

  @override
  void initState() {
    super.initState();
    context.read<TicketFcmBloc>().add(const TicketRequested());
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 2) return;
    switch (index) {
      case 0:
        Navigator.of(context)
            .pushReplacementNamed(DashboardPemilikPage.routeName);
      case 1:
        Navigator.of(context)
            .pushReplacementNamed(VerifikasiPembayaranPage.routeName);
      case 3:
        Navigator.of(context)
            .pushReplacementNamed(PapanPengumumanPage.routeName);
      case 4:
        Navigator.of(context).pushReplacementNamed(MenuKelolaPage.routeName);
    }
  }

  List<KomplainModel> _filterKomplain(List<KomplainModel> semua) {
    return semua.where((k) {
      if (_filterIndex == 0) return k.statusKomplain == 'menunggu';
      if (_filterIndex == 1) return k.statusKomplain == 'sedang_diperbaiki';
      return k.statusKomplain == 'selesai';
    }).toList();
  }
=======
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
>>>>>>> 3794f9c95113a0379f74cdcbede3f9935190c627

  Future<void> _ubahStatusKomplain(
    KomplainModel item, {
    required String statusBaru,
    required String judulDialog,
    required String defaultCatatan,
  }) async {
    final catatanController = TextEditingController(
      text: (item.catatanKomplain != null && item.catatanKomplain!.isNotEmpty)
          ? item.catatanKomplain!
          : defaultCatatan,
    );

    final catatan = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          '$judulDialog • ${item.kodeKamar}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan catatan teknisi atau jadwal penanganan untuk ${item.namaPenghuni}:',
              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: catatanController,
              maxLines: 3,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Tulis catatan penanganan...',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final teks = catatanController.text.trim();
              Navigator.of(ctx).pop(teks.isEmpty ? defaultCatatan : teks);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: statusBaru == 'selesai'
                  ? const Color(0xFF15803D)
                  : const Color(0xFF1D4ED8),
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan & Kirim Notifikasi'),
          ),
        ],
      ),
    );

    if (catatan != null && mounted) {
      context.read<TicketFcmBloc>().add(
        TicketUpdated(
          idKomplain: item.idKomplain,
          statusBaru: statusBaru,
          catatanTeknisi: catatan,
        ),
      );
    }
  }

<<<<<<< HEAD
  void _perbesarFoto(KomplainModel item) {
    final foto = item.fotoKomplain;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Foto Inspeksi • Kamar ${item.kodeKamar}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildFotoWidget(foto, height: 220),
            ),
            const SizedBox(height: 10),
            Text(
              item.judulKomplain,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
=======
      // Bottom Navigation Bar
      bottomNavigationBar: const PemilikBottomNav(currentIndex: 2),
>>>>>>> 3794f9c95113a0379f74cdcbede3f9935190c627
    );
  }

  Widget _buildFotoWidget(String? path, {double height = 140}) {
    if (path != null && path.startsWith('http')) {
      return Image.network(
        path,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fotoFallback(height),
      );
    }
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      return Image.file(
        File(path),
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return _fotoFallback(height);
  }

  Widget _fotoFallback(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFFDBEAFE),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_camera_back, color: Color(0xFF1D4ED8), size: 36),
          SizedBox(height: 4),
          Text(
            'Lampiran Foto Kerusakan',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D4ED8),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verifikasiMenunggu = context.select<PaymentVerifyBloc, int>((bloc) {
      final payState = bloc.state;
      if (payState is PaymentVerifyLoaded) {
        return payState.daftarPembayaran
            .where((p) => p.statusPembayaran == 'menunggu_verifikasi')
            .length;
      }
      return 0;
    });

    return BlocConsumer<TicketFcmBloc, TicketFcmState>(
      listener: (context, state) {
        if (state is TicketFcmLoaded && state.actionMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.actionMessage!)));
        } else if (state is TicketFcmFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFFDC2626),
                content: Text(state.message),
              ),
            );
        }
      },
      builder: (context, state) {
        final isLoading =
            state is TicketFcmInitial || state is TicketFcmLoading;
        final semua = state is TicketFcmLoaded
            ? state.daftarKomplain
            : const <KomplainModel>[];

        final jumlahMenunggu = semua
            .where((k) => k.statusKomplain == 'menunggu')
            .length;
        final jumlahDikerjakan = semua
            .where((k) => k.statusKomplain == 'sedang_diperbaiki')
            .length;
        final daftarSelesai = semua
            .where((k) => k.statusKomplain == 'selesai')
            .toList();
        final jumlahSelesai = daftarSelesai.length;
        final komplainAktif = jumlahMenunggu + jumlahDikerjakan;

        final filteredList = _filterKomplain(semua);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 16,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.apartment,
                    color: Color(0xFF1D4ED8),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'KosAsih',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Mode Pemilik',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Color(0xFF1E293B),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(PapanPengumumanPage.routeName);
                    },
                  ),
                  if (komplainAktif > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$komplainAktif',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(right: 16, left: 4),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF1D4ED8),
                  child: Icon(Icons.person, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: isLoading && semua.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      context.read<TicketFcmBloc>().add(
                        const TicketRequested(),
                      );
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Komplain Fasilitas',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'KosAsih Residence • Pemeliharaan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    setState(() => _filterIndex = 2),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDBEAFE),
                                  foregroundColor: const Color(0xFF1D4ED8),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.assignment_turned_in,
                                  size: 14,
                                ),
                                label: const Text(
                                  'Riwayat Selesai',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Banner Biru Ringkasan Komplain
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E40AF), Color(0xFF1D4ED8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.receipt_long,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'RINGKASAN KOMPLAIN',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0x33FFFFFF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Okt 2026',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    _buildSummaryBox(
                                      'Perlu Ditinjau',
                                      '$jumlahMenunggu',
                                      'Perlu Aksi',
                                      const Color(0xFFFDBA74),
                                      const Color(0x33F97316),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildSummaryBox(
                                      'Dikerjakan',
                                      '$jumlahDikerjakan',
                                      jumlahDikerjakan > 0
                                          ? 'Berjalan'
                                          : 'Standby',
                                      Colors.white70,
                                      const Color(0x22FFFFFF),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildSummaryBox(
                                      'Selesai (Bulan Ini)',
                                      '$jumlahSelesai',
                                      'Tertangani',
                                      const Color(0xFF86EFAC),
                                      const Color(0x3322C55E),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.sync,
                                      size: 12,
                                      color: Colors.white70,
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Sinkronisasi TicketFcmBloc aktif • Notifikasi FCM terhubung ke penghuni',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Filter Tabs
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip(
                                  'Perlu Ditinjau ($jumlahMenunggu)',
                                  isSelected: _filterIndex == 0,
                                  icon: Icons.error_outline,
                                  onTap: () => setState(() => _filterIndex = 0),
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  'Sedang Diperbaiki ($jumlahDikerjakan)',
                                  isSelected: _filterIndex == 1,
                                  icon: Icons.build_circle_outlined,
                                  onTap: () => setState(() => _filterIndex = 1),
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  'Selesai ($jumlahSelesai)',
                                  isSelected: _filterIndex == 2,
                                  icon: Icons.check_circle_outline,
                                  onTap: () => setState(() => _filterIndex = 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Text(
                                _filterIndex == 0
                                    ? 'Laporan Kerusakan Masuk'
                                    : _filterIndex == 1
                                    ? 'Dalam Proses Perbaikan'
                                    : 'Daftar Komplain Selesai',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (jumlahMenunggu > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$jumlahMenunggu Perlu Ditanggapi',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFEF4444),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (filteredList.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFF1F5F9),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Tidak ada tiket komplain pada kategori ini.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            )
                          else
                            ...filteredList.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _buildKomplainCard(
                                  item,
                                  isSubmitting: isLoading,
                                ),
                              ),
                            ),

                          if (_filterIndex != 2 &&
                              daftarSelesai.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Riwayat Perbaikan Selesai\nTerakhir',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                    height: 1.2,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      setState(() => _filterIndex = 2),
                                  child: const Text(
                                    'Lihat\nArsip',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1D4ED8),
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...daftarSelesai
                                .take(2)
                                .map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildRiwayatCard(
                                      kamarPenghuni:
                                          'Kamar ${item.kodeKamar} • ${item.namaPenghuni}',
                                      tanggalSelesai:
                                          'Selesai: ${item.tglKomplain}',
                                      judul: item.judulKomplain,
                                      catatan: item.catatanKomplain ?? 'Perbaikan telah diselesaikan oleh teknisi.',
                                      iconBg: const Color(0xFFDCFCE7),
                                      iconColor: const Color(0xFF16A34A),
                                      iconData: Icons.check_circle_outline,
                                    ),
                                  ),
                                ),
                          ],
                        ],
                      ),
                    ),
                  ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 2,
            onTap: (index) => _onNavTap(context, index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF1D4ED8),
            unselectedItemColor: const Color(0xFF64748B),
            selectedFontSize: 11,
            unselectedFontSize: 11,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: verifikasiMenunggu > 0,
                  label: Text('$verifikasiMenunggu'),
                  child: const Icon(Icons.assignment_outlined),
                ),
                label: 'Verifikasi',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: komplainAktif > 0,
                  label: Text('$komplainAktif'),
                  child: const Icon(Icons.build_circle),
                ),
                label: 'Komplain',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.campaign_outlined),
                label: 'Pengumuman',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                label: 'Kelola',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKomplainCard(KomplainModel item, {required bool isSubmitting}) {
    final isMenunggu = item.statusKomplain == 'menunggu';
    final isDikerjakan = item.statusKomplain == 'sedang_diperbaiki';
    final statusLabel = isMenunggu
        ? 'MENUNGGU TINJAUAN'
        : isDikerjakan
        ? 'SEDANG DIPERBAIKI'
        : 'SELESAI';
    final statusColor = isMenunggu
        ? const Color(0xFFEA580C)
        : isDikerjakan
        ? const Color(0xFF1D4ED8)
        : const Color(0xFF15803D);

    final namaFoto = (item.fotoKomplain == null || item.fotoKomplain!.isEmpty)
        ? 'bukti_${item.kodeKamar.toLowerCase()}.jpg'
        : item.fotoKomplain!.replaceAll('\\', '/').split('/').last;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'KAMAR',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC2410C),
                      ),
                    ),
                    Text(
                      item.kodeKamar,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC2410C),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.namaPenghuni,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dilaporkan: ${item.tglKomplain} • ${item.kodeTiket}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.build_outlined,
                      size: 12,
                      color: Color(0xFF1D4ED8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.kategoriFasilitas,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 12,
                      color: Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Prioritas ${item.prioritas}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.judulKomplain,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '"${item.deskripsiKomplain}"',
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xFF334155),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _perbesarFoto(item),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.image_outlined,
                              size: 14,
                              color: Color(0xFF475569),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                namaFoto,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.search,
                              size: 11,
                              color: Color(0xFF1D4ED8),
                            ),
                            SizedBox(width: 2),
                            Text(
                              'Periksa Foto',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        _buildFotoWidget(item.fotoKomplain, height: 140),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          color: Colors.black.withValues(alpha: 0.5),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.touch_app,
                                size: 12,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Ketuk untuk memperbesar foto inspeksi',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (item.catatanKomplain != null &&
              item.catatanKomplain!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 14,
                        color: Color(0xFF1E293B),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Catatan Tanggapan / Jadwal Teknisi Bu Asih:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.catatanKomplain!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (item.statusKomplain != 'selesai') ...[
            const SizedBox(height: 14),
            const Text(
              'Ubah Status Penanganan',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            if (isMenunggu) ...[
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : () => _ubahStatusKomplain(
                          item,
                          statusBaru: 'sedang_diperbaiki',
                          judulDialog: 'Proses Perbaikan',
                          defaultCatatan: 'Teknisi dijadwalkan mengecek kerusakan hari ini.',
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.build_outlined, size: 16),
                  label: const Text(
                    'Tandai Sedang Diperbaiki',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: isSubmitting
                    ? null
                    : () => _ubahStatusKomplain(
                        item,
                        statusBaru: 'selesai',
                        judulDialog: 'Selesaikan Komplain',
                        defaultCatatan: 'Perbaikan telah selesai dilakukan dan fasilitas berfungsi normal.',
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF15803D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text(
                  'Selesai Perbaikan',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildSummaryBox(
    String title,
    String count,
    String tag,
    Color tagColor,
    Color tagBg,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: tagBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: tagColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildFilterChip(
    String label, {
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1D4ED8) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1D4ED8)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475563),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildRiwayatCard({
    required String kamarPenghuni,
    required String tanggalSelesai,
    required String judul,
    required String catatan,
    required Color iconBg,
    required Color iconColor,
    required IconData iconData,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kamarPenghuni,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      tanggalSelesai,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'SELESAI',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            judul,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF475563),
                  height: 1.3,
                ),
                children: [
                  const TextSpan(
                    text: 'Catatan Teknisi: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: catatan),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
