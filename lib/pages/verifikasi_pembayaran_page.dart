import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/pembayaran_model.dart';
import '../logic/payment_verify_bloc/payment_verify_bloc.dart';
import '../logic/payment_verify_bloc/payment_verify_event.dart';
import '../logic/payment_verify_bloc/payment_verify_state.dart';
import '../logic/ticket_fcm_bloc/ticket_fcm_bloc.dart';
import '../logic/ticket_fcm_bloc/ticket_fcm_state.dart';
import 'dashboard_pemilik_page.dart';
import 'komplain_fasilitas_page.dart';
import 'menu_kelola_page.dart';
import 'papan_pengumuman_page.dart';

/// Halaman Verifikasi Bukti Pembayaran (mode Pemilik).
class VerifikasiPembayaranPage extends StatefulWidget {
  const VerifikasiPembayaranPage({super.key});

  /// Nama route, dipakai oleh `main.dart`.
  static const String routeName = '/verifikasi-pembayaran';

  @override
  State<VerifikasiPembayaranPage> createState() =>
      _VerifikasiPembayaranPageState();
}

class _VerifikasiPembayaranPageState extends State<VerifikasiPembayaranPage> {
  int _filterIndex = 0; // 0 = Perlu Dicek, 1 = Lunas, 2 = Ditolak

  @override
  void initState() {
    super.initState();
    context.read<PaymentVerifyBloc>().add(const PaymentVerificationRequested());
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 1) return;
    switch (index) {
      case 0:
        Navigator.of(context)
            .pushReplacementNamed(DashboardPemilikPage.routeName);
      case 2:
        Navigator.of(context)
            .pushReplacementNamed(KomplainFasilitasPage.routeName);
      case 3:
        Navigator.of(context)
            .pushReplacementNamed(PapanPengumumanPage.routeName);
      case 4:
        Navigator.of(context).pushReplacementNamed(MenuKelolaPage.routeName);
    }
  }

  String _formatRupiah(int nominal) {
    final absVal = nominal.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < absVal.length; i++) {
      final posFromRight = absVal.length - i;
      buffer.write(absVal[i]);
      if (posFromRight > 1 && posFromRight % 3 == 1) {
        buffer.write('.');
      }
    }
    return '${nominal < 0 ? '-' : ''}Rp $buffer';
  }

  String _namaFileDariPath(String? path) {
    if (path == null || path.trim().isEmpty) return 'bukti_pembayaran.jpg';
    final normalized = path.replaceAll('\\', '/');
    return normalized.split('/').last;
  }

  List<PembayaranModel> _filterDaftar(List<PembayaranModel> semua) {
    return semua.where((item) {
      final ditolak =
          item.alasanPenolakan != null && item.alasanPenolakan!.isNotEmpty;
      if (_filterIndex == 0) {
        return item.statusPembayaran == 'menunggu_verifikasi';
      } else if (_filterIndex == 1) {
        return item.statusPembayaran == 'lunas';
      } else {
        return ditolak && item.statusPembayaran != 'lunas';
      }
    }).toList();
  }

  Future<void> _konfirmasiTolakBukti(PembayaranModel item) async {
    final alasanController = TextEditingController(
      text: 'Nominal transfer tidak sesuai atau foto struk kurang jelas.',
    );

    final alasan = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Tolak Bukti • Kamar ${item.kodeKamar}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan alasan penolakan untuk ${item.namaPenghuni} agar dapat mengunggah ulang bukti transfer:',
              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: alasanController,
              maxLines: 3,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Contoh: Foto struk terpotong / nominal kurang',
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
              final teks = alasanController.text.trim();
              Navigator.of(
                ctx,
              ).pop(teks.isEmpty ? 'Bukti pembayaran ditolak pemilik.' : teks);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Tolak Bukti'),
          ),
        ],
      ),
    );

    if (alasan != null && mounted) {
      context.read<PaymentVerifyBloc>().add(
        PaymentRejected(
          idPembayaran: item.idPembayaran,
          alasanPenolakan: alasan,
        ),
      );
    }
  }

  void _tampilkanPratinjauBukti(PembayaranModel item) {
    final namaFile = _namaFileDariPath(item.buktiPembayaran);
    final infoFile =
        '${item.metodePembayaran} • Periode ${item.periodePembayaran}';

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Bukti Bayar • Kamar ${item.kodeKamar}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFC7D7F8)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long,
                    size: 44,
                    color: Color(0xFF1545C7),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      namaFile,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    infoFile,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Nominal Ditransfer: ${_formatRupiah(item.totalTagihan)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1545C7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Penghuni: ${item.namaPenghuni} (${item.metodePembayaran})',
              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
            ),
            if (item.kuitansiPembayaran != null &&
                item.kuitansiPembayaran!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'E-Kwitansi: ${item.kuitansiPembayaran}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF15803D),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final komplainAktif = context.select<TicketFcmBloc, int>((bloc) {
      final ticketState = bloc.state;
      if (ticketState is TicketFcmLoaded) {
        return ticketState.daftarKomplain
            .where((k) => k.statusKomplain != 'selesai')
            .length;
      }
      return 0;
    });

    return BlocConsumer<PaymentVerifyBloc, PaymentVerifyState>(
      listener: (context, state) {
        if (state is PaymentVerifyLoaded && state.actionMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.actionMessage!)));
        } else if (state is PaymentVerifyFailure) {
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
            state is PaymentVerifyInitial || state is PaymentVerifyLoading;
        final semua = state is PaymentVerifyLoaded
            ? state.daftarPembayaran
            : const <PembayaranModel>[];
        final items = _filterDaftar(semua);

        final jumlahMenunggu = semua
            .where((e) => e.statusPembayaran == 'menunggu_verifikasi')
            .length;
        final jumlahLunas = semua
            .where((e) => e.statusPembayaran == 'lunas')
            .length;
        final jumlahDitolak = semua
            .where(
              (e) =>
                  e.alasanPenolakan != null &&
                  e.alasanPenolakan!.isNotEmpty &&
                  e.statusPembayaran != 'lunas',
            )
            .length;
        final jumlahBelumBayar = semua
            .where(
              (e) =>
                  e.statusPembayaran == 'belum_bayar' ||
                  e.statusPembayaran == 'terlambat',
            )
            .length;

        final totalNominalLunas = semua
            .where((e) => e.statusPembayaran == 'lunas')
            .fold<int>(0, (sum, e) => sum + e.totalTagihan);
        final persentaseLunas = semua.isEmpty
            ? 0
            : ((jumlahLunas / semua.length) * 100).round();

        final badgeMenunggu = jumlahMenunggu.toString();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FB),
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
                    color: const Color(0xFFEEF4FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.apartment,
                    color: Color(0xFF1545C7),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'KosAsih',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
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
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 7, color: Color(0xFF15803D)),
                      SizedBox(width: 4),
                      Text(
                        'Mode Pemilik',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
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
                      color: Color(0xFF111827),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(PapanPengumumanPage.routeName);
                    },
                  ),
                  if (jumlahMenunggu > 0)
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
                          badgeMenunggu,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: Color(0xFF1545C7),
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          body: isLoading && semua.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<PaymentVerifyBloc>().add(
                      const PaymentVerificationRequested(),
                    );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Verifikasi Bukti Pembayaran',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 7,
                                        color: Color(0xFF15803D),
                                      ),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'KosAsih Residence • Periode Oktober 2026',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => setState(() => _filterIndex = 1),
                              icon: const Icon(
                                Icons.receipt_long_outlined,
                                size: 15,
                              ),
                              label: const Text(
                                'Riwayat Lunas',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEEF4FF),
                                foregroundColor: const Color(0xFF1545C7),
                                surfaceTintColor: Colors.transparent,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Kartu Ringkasan Biru
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2358E0), Color(0xFF1545C7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x331545C7),
                                blurRadius: 16,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.fact_check_outlined,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'STATUS ANTREAN VERIFIKASI',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0x26FFFFFF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Oktober 2026',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  _buildSummaryTile(
                                    label: 'Perlu Dicek',
                                    trailingIcon: const Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: Color(0xFFF59E0B),
                                    ),
                                    value: '$jumlahMenunggu Kamar',
                                    valueColor: Colors.white,
                                    footerWidget: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEDD5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Tindakan Segera',
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF9A3412),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildSummaryTile(
                                    label: 'Sudah Lunas',
                                    trailingIcon: const Icon(
                                      Icons.check_circle_outline,
                                      size: 13,
                                      color: Color(0xFF4ADE80),
                                    ),
                                    value: '$jumlahLunas\nKamar',
                                    valueColor: const Color(0xFF4ADE80),
                                    footerWidget: const Text(
                                      'Otomatis sync',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildSummaryTile(
                                    label: 'Belum Bayar',
                                    trailingIcon: const Icon(
                                      Icons.more_horiz,
                                      size: 13,
                                      color: Colors.white70,
                                    ),
                                    value: '$jumlahBelumBayar Kamar',
                                    valueColor: Colors.white,
                                    footerWidget: const Text(
                                      'Jatuh tempo',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0x18FFFFFF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.sync,
                                      size: 14,
                                      color: Color(0xFF4ADE80),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Total ${semua.length} Tagihan Aktif',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${_formatRupiah(totalNominalLunas)} ',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      '($persentaseLunas%)',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4ADE80),
                                      ),
                                    ),
                                  ],
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
                              _buildFilterTab(
                                label: 'Perlu Dicek',
                                count: jumlahMenunggu,
                                selected: _filterIndex == 0,
                                onTap: () => setState(() => _filterIndex = 0),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterTab(
                                label: 'Lunas / E-Kwitansi',
                                count: jumlahLunas,
                                selected: _filterIndex == 1,
                                onTap: () => setState(() => _filterIndex = 1),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterTab(
                                label: 'Ditolak',
                                count: jumlahDitolak,
                                selected: _filterIndex == 2,
                                onTap: () => setState(() => _filterIndex = 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Header Daftar Antrean
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _filterIndex == 0
                                  ? 'Antrean Struk Transfer Masuk'
                                  : _filterIndex == 1
                                  ? 'Pembayaran Terverifikasi'
                                  : 'Bukti Pembayaran Ditolak',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const Text(
                              'Prioritas Terlama',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (items.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 36,
                                  color: Color(0xFF9CA3AF),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Belum ada data pada kategori ini',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _buildPaymentCard(
                                item,
                                isSubmitting: isLoading,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 1,
            onTap: (index) => _onNavTap(context, index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF1545C7),
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
                  isLabelVisible: jumlahMenunggu > 0,
                  label: Text(badgeMenunggu),
                  child: const Icon(Icons.verified_user),
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

  Widget _buildSummaryTile({
    required String label,
    required Widget trailingIcon,
    required String value,
    required Color valueColor,
    required Widget footerWidget,
  }) {
    return Expanded(
      child: Container(
        height: 116,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0x1FFFFFFF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ),
                trailingIcon,
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                height: 1.15,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            const Spacer(),
            footerWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1545C7) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? const Color(0xFF1545C7) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : const Color(0xFF374151),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected ? Colors.white : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: selected
                      ? const Color(0xFF1545C7)
                      : const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(PembayaranModel item, {required bool isSubmitting}) {
    final bool isMenunggu = item.statusPembayaran == 'menunggu_verifikasi';
    final bool isLunas = item.statusPembayaran == 'lunas';

    final Color badgeBg = isMenunggu
        ? const Color(0xFFFFEDD5)
        : isLunas
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEE2E2);
    final Color badgeTextColor = isMenunggu
        ? const Color(0xFFC2410C)
        : isLunas
        ? const Color(0xFF15803D)
        : const Color(0xFFB91C1C);
    final String badgeLabel = isMenunggu
        ? '• MENUNGGU DICEK'
        : isLunas
        ? '✓ LUNAS'
        : '✕ DITOLAK';

    final namaFile = _namaFileDariPath(item.buktiPembayaran);
    final jumlahItemTagihan =
        1 +
        (item.biayaTamuPembayaran > 0 ? 1 : 0) +
        (item.dendaPembayaran > 0 ? 1 : 0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
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
                width: 48,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.kodeKamar,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1545C7),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namaPenghuni,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.infoKamar.isEmpty
                          ? 'Periode ${item.periodePembayaran}'
                          : item.infoKamar,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.access_time,
                  size: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF475569),
                    ),
                    children: [
                      TextSpan(
                        text: isLunas && item.tglLunasPembayaran != null
                            ? 'Lunas pada: '
                            : 'Tenggat: ',
                      ),
                      TextSpan(
                        text: isLunas && item.tglLunasPembayaran != null
                            ? item.tglLunasPembayaran!
                            : item.tenggatPembayaran,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      TextSpan(
                        text: ' (Via ${item.metodePembayaran})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1545C7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (item.alasanPenolakan != null &&
              item.alasanPenolakan!.isNotEmpty &&
              !isLunas) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Text(
                'Alasan Penolakan: ${item.alasanPenolakan}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB91C1C),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Rincian Komponen Tagihan:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: item.hariTerlambat > 0
                            ? const Color(0xFFDBEAFE)
                            : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.hariTerlambat > 0
                            ? '$jumlahItemTagihan Item'
                            : 'Tepat Waktu',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: item.hariTerlambat > 0
                              ? const Color(0xFF1545C7)
                              : const Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildDetailLine(
                  'Sewa Kamar Pokok (${item.periodePembayaran})',
                  _formatRupiah(item.nominalPembayaran),
                ),
                const SizedBox(height: 4),
                _buildDetailLine(
                  'Biaya Tamu Menginap',
                  item.biayaTamuPembayaran > 0
                      ? _formatRupiah(item.biayaTamuPembayaran)
                      : 'Rp 0 (Nihil)',
                  valueColor: item.biayaTamuPembayaran > 0
                      ? const Color(0xFF111827)
                      : const Color(0xFF15803D),
                ),
                if (item.dendaPembayaran > 0 || item.hariTerlambat > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 13,
                            color: Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Denda Keterlambatan (${item.hariTerlambat} Hari)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '+${_formatRupiah(item.dendaPembayaran)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Ditransfer:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      _formatRupiah(item.totalTagihan),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1545C7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF4FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.metodePembayaran.contains('BCA') ||
                            item.metodePembayaran.contains('Bank')
                        ? Icons.account_balance
                        : Icons.account_balance_wallet,
                    size: 18,
                    color: const Color(0xFF1545C7),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        namaFile,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1545C7),
                        ),
                      ),
                      Text(
                        '${item.metodePembayaran} • ${item.periodePembayaran}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _tampilkanPratinjauBukti(item),
                  icon: const Icon(Icons.zoom_in, size: 14),
                  label: const Text(
                    'Periksa Bukti',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1545C7),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFC7D7F8)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (isMenunggu) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: isSubmitting
                        ? null
                        : () => _konfirmasiTolakBukti(item),
                    icon: const Icon(Icons.close, size: 15),
                    label: const Text(
                      'Tolak Bukti',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEE2E2),
                      foregroundColor: const Color(0xFFDC2626),
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            context.read<PaymentVerifyBloc>().add(
                              PaymentApproved(item.idPembayaran),
                            );
                          },
                    icon: const Icon(Icons.verified_outlined, size: 15),
                    label: const Text(
                      'Verifikasi & Terbitkan E-Kwitansi',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1545C7),
                      foregroundColor: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailLine(
    String label,
    String value, {
    Color valueColor = const Color(0xFF111827),
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
