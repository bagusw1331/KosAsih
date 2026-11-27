import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/pengumuman_model.dart';
import '../logic/payment_verify_bloc/payment_verify_bloc.dart';
import '../logic/payment_verify_bloc/payment_verify_state.dart';
import '../logic/ticket_fcm_bloc/ticket_fcm_bloc.dart';
import '../logic/ticket_fcm_bloc/ticket_fcm_event.dart';
import '../logic/ticket_fcm_bloc/ticket_fcm_state.dart';
import 'dashboard_pemilik_page.dart';
import 'komplain_fasilitas_page.dart';
import 'menu_kelola_page.dart';
import 'verifikasi_pembayaran_page.dart';

class PapanPengumumanPage extends StatefulWidget {
  const PapanPengumumanPage({super.key});

  /// Nama route, dipakai oleh `main.dart`.
  static const String routeName = '/papan-pengumuman';

  @override
  State<PapanPengumumanPage> createState() => _PapanPengumumanPageState();
}

class _PapanPengumumanPageState extends State<PapanPengumumanPage> {
  int _filterIndex = 0; // 0 = Semua, 1 = Disematkan, 2 = Air & Tandon

  @override
  void initState() {
    super.initState();
    context.read<TicketFcmBloc>().add(const TicketRequested());
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 3) return;
    switch (index) {
      case 0:
        Navigator.of(context)
            .pushReplacementNamed(DashboardPemilikPage.routeName);
      case 1:
        Navigator.of(context)
            .pushReplacementNamed(VerifikasiPembayaranPage.routeName);
      case 2:
        Navigator.of(context)
            .pushReplacementNamed(KomplainFasilitasPage.routeName);
      case 4:
        Navigator.of(context).pushReplacementNamed(MenuKelolaPage.routeName);
    }
  }

  List<PengumumanModel> _filterPengumuman(List<PengumumanModel> semua) {
    final sorted = [...semua]
      ..sort((a, b) {
        if (a.pinPengumuman == b.pinPengumuman) return 0;
        return a.pinPengumuman ? -1 : 1;
      });
    if (_filterIndex == 1) {
      return sorted.where((e) => e.pinPengumuman).toList();
    }
    if (_filterIndex == 2) {
      return sorted
          .where((e) => e.kategoriPengumuman.toLowerCase().contains('air'))
          .toList();
    }
    return sorted;
  }

  Future<void> _bukaFormPengumuman({PengumumanModel? existing}) async {
    final judulController = TextEditingController(
      text: existing?.judulPengumuman ?? '',
    );
    final isiController = TextEditingController(
      text: existing?.isiPengumuman ?? '',
    );
    String kategori = existing?.kategoriPengumuman ?? 'Informasi Umum';
    bool pin = existing?.pinPengumuman ?? false;

    const daftarKategori = [
      'Informasi Umum',
      'Air & Tandon',
      'Jaringan WiFi',
      'Ketertiban Umum',
      'Pemeliharaan',
    ];
    if (!daftarKategori.contains(kategori)) {
      kategori = 'Informasi Umum';
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            existing == null ? 'Buat Siaran Pengumuman' : 'Edit Pengumuman',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: judulController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Judul Pengumuman',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: kategori,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: daftarKategori
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => kategori = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: isiController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    labelText: 'Isi Siaran Pengumuman',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Sematkan di Paling Atas (Pin)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  value: pin,
                  activeThumbColor: const Color(0xFF1D4ED8),
                  onChanged: (val) => setDialogState(() => pin = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final judul = judulController.text.trim();
                final isi = isiController.text.trim();
                if (judul.isEmpty || isi.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Judul dan isi pengumuman wajib diisi.'),
                    ),
                  );
                  return;
                }
                if (existing == null) {
                  context.read<TicketFcmBloc>().add(
                    AnnouncementBroadcasted(
                      judul: judul,
                      isi: isi,
                      kategori: kategori,
                      pin: pin,
                    ),
                  );
                } else {
                  context.read<TicketFcmBloc>().add(
                    AnnouncementUpdated(
                      idPengumuman: existing.idPengumuman,
                      judul: judul,
                      isi: isi,
                      kategori: kategori,
                      pin: pin,
                    ),
                  );
                }
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.campaign, size: 16),
              label: Text(existing == null ? 'Siarkan FCM' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _konfirmasiHapus(PengumumanModel item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Hapus Pengumuman?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Pengumuman "${item.judulPengumuman}" akan dihapus dari papan informasi penghuni.',
          style: const TextStyle(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      context.read<TicketFcmBloc>().add(AnnouncementDeleted(item.idPengumuman));
    }
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
            ? state.daftarPengumuman
            : const <PengumumanModel>[];
        final komplainAktif = state is TicketFcmLoaded
            ? state.daftarKomplain
                  .where((k) => k.statusKomplain != 'selesai')
                  .length
            : 0;

        final jumlahPin = semua.where((e) => e.pinPengumuman).length;
        final daftarTampil = _filterPengumuman(semua);

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
                    onPressed: () {},
                  ),
                  if (semua.isNotEmpty)
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
                          '${semua.length}',
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
                          const Text(
                            'Papan Pengumuman & Siaran Massal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: Color(0xFF1D4ED8),
                              ),
                              SizedBox(width: 2),
                              Text(
                                'KosAsih Residence • Siaran ke Semua Kamar',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Banner Biru Ringkasan Siaran
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
                                          Icons.campaign,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'RINGKASAN SIARAN\nPENGUMUMAN',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 1.2,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0x33FFFFFF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Oktober\n2026',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          height: 1.1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    _buildSummaryBox(
                                      'Target Penerima',
                                      '16 Kamar',
                                      'Kamar Terisi',
                                    ),
                                    const SizedBox(width: 8),
                                    _buildSummaryBox(
                                      'Disematkan (Pin)',
                                      '$jumlahPin Info',
                                      'Prioritas Atas',
                                    ),
                                    const SizedBox(width: 8),
                                    _buildSummaryBox(
                                      'Siaran Bulan Ini',
                                      '${semua.length} Siaran',
                                      'Terkirim FCM',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Card Buat Siaran Baru
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFF1F5F9),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.add_comment_outlined,
                                    color: Color(0xFF1D4ED8),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Buat Siaran Baru',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Kirim info & notifikasi FCM',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: isLoading
                                      ? null
                                      : () => _bukaFormPengumuman(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1D4ED8),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text(
                                    'Buat Baru',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Filter Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip(
                                  'Semua (${semua.length})',
                                  isSelected: _filterIndex == 0,
                                  onTap: () => setState(() => _filterIndex = 0),
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  'Disematkan ($jumlahPin)',
                                  isSelected: _filterIndex == 1,
                                  icon: Icons.push_pin_outlined,
                                  iconColor: Colors.red,
                                  onTap: () => setState(() => _filterIndex = 1),
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  'Air & Tandon',
                                  isSelected: _filterIndex == 2,
                                  icon: Icons.water_drop_outlined,
                                  iconColor: Colors.blue,
                                  onTap: () => setState(() => _filterIndex = 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Daftar Pengumuman Aktif',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${daftarTampil.length} Siaran Terbit',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (daftarTampil.isEmpty)
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
                                  'Belum ada pengumuman pada kategori ini.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            )
                          else
                            ...daftarTampil.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildPengumumanCard(item),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 3,
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
                  child: const Icon(Icons.build_circle_outlined),
                ),
                label: 'Komplain',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.campaign),
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

  Widget _buildPengumumanCard(PengumumanModel item) {
    final lowerKat = item.kategoriPengumuman.toLowerCase();
    final IconData iconData = lowerKat.contains('air')
        ? Icons.water_drop_outlined
        : lowerKat.contains('wifi')
        ? Icons.wifi
        : lowerKat.contains('tertib')
        ? Icons.lock_outline
        : Icons.campaign_outlined;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.pinPengumuman
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  color: item.pinPengumuman
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.judulPengumuman,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF64748B),
                        ),
                        children: [
                          TextSpan(
                            text:
                                '${item.kategoriPengumuman}  •  ${item.tglPengumuman}  •  ',
                          ),
                          TextSpan(
                            text: item.penulisPengumuman,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.pinPengumuman
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.pinPengumuman) ...[
                      const Icon(
                        Icons.check,
                        size: 10,
                        color: Color(0xFF15803D),
                      ),
                      const SizedBox(width: 2),
                    ],
                    Text(
                      item.pinPengumuman ? 'DISEMATKAN' : 'TERKIRIM',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: item.pinPengumuman
                            ? const Color(0xFF15803D)
                            : const Color(0xFF1D4ED8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.isiPengumuman,
              style: const TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xFF334155),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                'Hapus',
                Icons.delete_outline,
                const Color(0xFFFEE2E2),
                const Color(0xFFDC2626),
                onTap: () => _konfirmasiHapus(item),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                'Edit Info',
                Icons.edit_outlined,
                const Color(0xFFDBEAFE),
                const Color(0xFF1D4ED8),
                onTap: () => _bukaFormPengumuman(existing: item),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildSummaryBox(String title, String count, String sub) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: const TextStyle(fontSize: 8, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildFilterChip(
    String label, {
    required bool isSelected,
    IconData? icon,
    Color? iconColor,
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
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : iconColor,
              ),
              const SizedBox(width: 4),
            ],
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

  static Widget _buildActionButton(
    String label,
    IconData icon,
    Color bg,
    Color text, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: text),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
