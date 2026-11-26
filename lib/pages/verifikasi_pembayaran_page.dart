import 'package:flutter/material.dart';

import '../widgets/kosasih_bottom_nav.dart';

/// Halaman Verifikasi Bukti Pembayaran (mode Pemilik).
class VerifikasiPembayaranPage extends StatefulWidget {
  const VerifikasiPembayaranPage({super.key});

  /// Nama route, dipakai oleh `main.dart`.
  static const String routeName = '/verifikasi-pembayaran';

  @override
  State<VerifikasiPembayaranPage> createState() =>
      _VerifikasiPembayaranPageState();
}

enum _StatusVerifikasi { menunggu, lunas, ditolak }

class _ItemPembayaran {
  const _ItemPembayaran({
    required this.kodeKamar,
    required this.namaPenghuni,
    required this.infoKamar,
    required this.waktuUnggah,
    required this.metode,
    required this.sewaPokok,
    required this.biayaTamu,
    required this.denda,
    required this.hariTerlambat,
    required this.total,
    required this.namaFile,
    required this.infoFile,
    required this.status,
  });

  final String kodeKamar;
  final String namaPenghuni;
  final String infoKamar;
  final String waktuUnggah;
  final String metode;
  final String sewaPokok;
  final String biayaTamu;
  final String denda;
  final int hariTerlambat;
  final String total;
  final String namaFile;
  final String infoFile;
  final _StatusVerifikasi status;

  _ItemPembayaran copyWith({_StatusVerifikasi? status}) {
    return _ItemPembayaran(
      kodeKamar: kodeKamar,
      namaPenghuni: namaPenghuni,
      infoKamar: infoKamar,
      waktuUnggah: waktuUnggah,
      metode: metode,
      sewaPokok: sewaPokok,
      biayaTamu: biayaTamu,
      denda: denda,
      hariTerlambat: hariTerlambat,
      total: total,
      namaFile: namaFile,
      infoFile: infoFile,
      status: status ?? this.status,
    );
  }
}

class _VerifikasiPembayaranPageState extends State<VerifikasiPembayaranPage> {
  int _filterIndex = 0; // 0 = Perlu Dicek, 1 = Lunas, 2 = Ditolak

  final List<_ItemPembayaran> _daftarBukti = [
    const _ItemPembayaran(
      kodeKamar: 'A-04',
      namaPenghuni: 'Bagus Wihandono',
      infoKamar: 'Kamar Utama AC • Lt 1',
      waktuUnggah: 'Hari ini, 15 Okt 2026 • 08:45 WIB',
      metode: 'Via Bank BCA',
      sewaPokok: 'Rp 1.200.000',
      biayaTamu: 'Rp 50.000',
      denda: '+Rp 40.000',
      hariTerlambat: 2,
      total: 'Rp 1.290.000',
      namaFile: 'bukti_transfer_bca_a04.jpg',
      infoFile: '420 KB • Bank BCA m-Transfer',
      status: _StatusVerifikasi.menunggu,
    ),
    const _ItemPembayaran(
      kodeKamar: 'B-01',
      namaPenghuni: 'Raka Pratama',
      infoKamar: 'Lantai 2 • Balkon Luar',
      waktuUnggah: 'Hari ini, 15 Okt 2026 • 09:10 WIB',
      metode: 'Via Bank Mandiri',
      sewaPokok: 'Rp 1.200.000',
      biayaTamu: 'Rp 0 (Nihil)',
      denda: '',
      hariTerlambat: 0,
      total: 'Rp 1.200.000',
      namaFile: 'bukti_transfer_mandiri_b01.jpg',
      infoFile: '380 KB • Mandiri Livin\' Transfer',
      status: _StatusVerifikasi.menunggu,
    ),
    const _ItemPembayaran(
      kodeKamar: 'A-02',
      namaPenghuni: 'Nadia Putri',
      infoKamar: 'Lantai 1 • Kamar Standar AC',
      waktuUnggah: '12 Okt 2026 • 14:20 WIB',
      metode: 'Via QRIS',
      sewaPokok: 'Rp 1.200.000',
      biayaTamu: 'Rp 0 (Nihil)',
      denda: '',
      hariTerlambat: 0,
      total: 'Rp 1.200.000',
      namaFile: 'qris_oktober_a02.png',
      infoFile: '290 KB • QRIS Instan Terverifikasi',
      status: _StatusVerifikasi.lunas,
    ),
  ];

  int get _jumlahMenunggu => _daftarBukti
      .where((e) => e.status == _StatusVerifikasi.menunggu)
      .length;

  int get _jumlahLunas =>
      13 +
      _daftarBukti.where((e) => e.status == _StatusVerifikasi.lunas).length;

  int get _jumlahDitolak =>
      _daftarBukti.where((e) => e.status == _StatusVerifikasi.ditolak).length;

  List<_ItemPembayaran> get _filteredItems {
    final target = switch (_filterIndex) {
      0 => _StatusVerifikasi.menunggu,
      1 => _StatusVerifikasi.lunas,
      _ => _StatusVerifikasi.ditolak,
    };
    return _daftarBukti.where((e) => e.status == target).toList();
  }

  void _ubahStatus(_ItemPembayaran item, _StatusVerifikasi baru, String pesan) {
    final idx = _daftarBukti.indexOf(item);
    if (idx == -1) return;
    setState(() {
      _daftarBukti[idx] = item.copyWith(status: baru);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  void _tampilkanPratinjauBukti(_ItemPembayaran item) {
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
                  Text(
                    item.namaFile,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.infoFile,
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
              'Nominal Ditransfer: ${item.total}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1545C7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Penghuni: ${item.namaPenghuni} (${item.metode})',
              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
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
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: const Color(0xFF1545C7),
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul & Tombol Riwayat Lunas
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Verifikasi Bukti Pembayaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: const [
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
                  icon: const Icon(Icons.receipt_long_outlined, size: 15),
                  label: const Text(
                    'Riwayat Lunas',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
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
                        value: '$_jumlahMenunggu Kamar',
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
                        value: '$_jumlahLunas\nKamar',
                        valueColor: const Color(0xFF4ADE80),
                        footerWidget: const Text(
                          'Otomatis sync',
                          style: TextStyle(fontSize: 9, color: Colors.white70),
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
                        value: '2 Kamar',
                        valueColor: Colors.white,
                        footerWidget: const Text(
                          'Jatuh tempo',
                          style: TextStyle(fontSize: 9, color: Colors.white70),
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
                        const Expanded(
                          child: Text(
                            'Total 16 Kamar Terisi',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const Text(
                          'Rp 18.250.000 ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          '(84%)',
                          style: TextStyle(
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
                    count: _jumlahMenunggu,
                    selected: _filterIndex == 0,
                    onTap: () => setState(() => _filterIndex = 0),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterTab(
                    label: 'Lunas / E-Kwitansi',
                    count: _jumlahLunas,
                    selected: _filterIndex == 1,
                    onTap: () => setState(() => _filterIndex = 1),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterTab(
                    label: 'Ditolak',
                    count: _jumlahDitolak,
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
                  style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
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
                  border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  child: _buildPaymentCard(item),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: PemilikBottomNav(
        currentIndex: 1,
        verifikasiBadge: _jumlahMenunggu,
      ),
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
                color: selected
                    ? Colors.white
                    : const Color(0xFFF3F4F6),
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

  Widget _buildPaymentCard(_ItemPembayaran item) {
    final bool isMenunggu = item.status == _StatusVerifikasi.menunggu;
    final bool isLunas = item.status == _StatusVerifikasi.lunas;

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
          // Header Penghuni & Status
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
                      item.infoKamar,
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

          // Waktu Upload
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
                      const TextSpan(text: 'Diunggah: '),
                      TextSpan(
                        text: item.waktuUnggah,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      TextSpan(
                        text: ' (${item.metode})',
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
          const SizedBox(height: 12),

          // Rincian Komponen Tagihan
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
                        item.hariTerlambat > 0 ? '3 Item' : 'Tepat Waktu',
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
                  item.hariTerlambat > 0
                      ? 'Sewa Kamar Pokok (AC, KM Dlm)'
                      : 'Sewa Kamar Pokok (Lt. 2, KM Dlm)',
                  item.sewaPokok,
                ),
                const SizedBox(height: 4),
                _buildDetailLine(
                  item.hariTerlambat > 0
                      ? 'Biaya Tamu Menginap (1 Org x 1 Mlm)'
                      : 'Biaya Tamu / Denda Keterlambatan',
                  item.biayaTamu,
                  valueColor: item.hariTerlambat > 0
                      ? const Color(0xFF111827)
                      : const Color(0xFF15803D),
                ),
                if (item.hariTerlambat > 0) ...[
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
                        item.denda,
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
                      item.total,
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

          // Lampiran Bukti Transfer
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
                    item.metode.contains('BCA')
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
                        item.namaFile,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1545C7),
                        ),
                      ),
                      Text(
                        item.infoFile,
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
                    onPressed: () => _ubahStatus(
                      item,
                      _StatusVerifikasi.ditolak,
                      'Bukti pembayaran ${item.kodeKamar} ditolak.',
                    ),
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
                    onPressed: () => _ubahStatus(
                      item,
                      _StatusVerifikasi.lunas,
                      'Pembayaran ${item.kodeKamar} diverifikasi & E-Kwitansi diterbitkan.',
                    ),
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
