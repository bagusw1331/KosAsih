import 'package:flutter/material.dart';

import 'komplain_fasilitas_page.dart';

/// Halaman Daftar & Kelola Kamar (mode Pemilik).
class KelolaKamarPage extends StatefulWidget {
  const KelolaKamarPage({super.key});

  /// Nama route, dipakai oleh `main.dart`.
  static const String routeName = '/kelola-kamar';

  @override
  State<KelolaKamarPage> createState() => _KelolaKamarPageState();
}

enum _StatusKamar { siapHuni, terisi, perbaikan }

class _DataKamar {
  const _DataKamar({
    required this.kode,
    required this.lantai,
    required this.subjudul,
    required this.harga,
    required this.labelHarga,
    required this.fasilitas,
    required this.status,
    required this.catatan,
    this.adaKomplainAktif = false,
    this.nomorTiket,
  });

  final String kode;
  final String lantai;
  final String subjudul;
  final String harga;
  final String labelHarga;
  final List<String> fasilitas;
  final _StatusKamar status;
  final String catatan;
  final bool adaKomplainAktif;
  final String? nomorTiket;
}

class _KelolaKamarPageState extends State<KelolaKamarPage> {
  final TextEditingController _searchController = TextEditingController();
  int _filterIndex = 0; // 0 = Semua, 1 = Kosong, 2 = Terisi

  final List<_DataKamar> _daftarKamar = [
    const _DataKamar(
      kode: 'A-08',
      lantai: 'Lt. 1',
      subjudul: 'KosAsih Residence Sayap Timur',
      harga: 'Rp 1.200.000',
      labelHarga: 'Tarif Sewa Reguler',
      fasilitas: [
        'AC 1/2 PK',
        'KM Dalam & Shower',
        'Kasur Springbed No. 2',
        'Wi-Fi 50 Mbps',
        'Lemari Pakaian',
      ],
      status: _StatusKamar.siapHuni,
      catatan:
          'Siap Huni: Bersih & Kunci Tersedia di Kantor (Tidak ada kerusakan fisik).',
    ),
    const _DataKamar(
      kode: 'B-09',
      lantai: 'Lt. 2',
      subjudul: 'KosAsih Sayap Barat (View Taman)',
      harga: 'Rp 1.200.000',
      labelHarga: 'Tarif Sewa Reguler',
      fasilitas: [
        'AC 1/2 PK',
        'KM Dalam',
        'Meja Belajar & Kursi',
        'Kasur Springbed',
        'Wi-Fi',
      ],
      status: _StatusKamar.siapHuni,
      catatan:
          'Siap Huni: Sirkulasi Udara Bagus, Jendela Menghadap Taman & Kolam Ikan.',
    ),
    const _DataKamar(
      kode: 'A-04',
      lantai: 'Lt. 1',
      subjudul: 'Penghuni: Dimas Bagus (S.d Jan 2027)',
      harga: 'Rp 1.200.000',
      labelHarga: 'Sewa Terkontrak',
      fasilitas: ['AC', 'KM Dalam', 'Kasur Springbed', 'Wi-Fi'],
      status: _StatusKamar.terisi,
      catatan:
          'AC Tidak Dingin & Menetes ke lantai. Teknisi AC dijadwalkan datang hari ini pukul 14.00 WIB.',
      adaKomplainAktif: true,
      nomorTiket: 'Tiket #TC-2026-088',
    ),
    const _DataKamar(
      kode: 'B-01',
      lantai: 'Lt. 2',
      subjudul: 'Penghuni: Sarah Kartika (S.d Nov 2026)',
      harga: 'Rp 1.200.000',
      labelHarga: 'Sewa Terkontrak',
      fasilitas: [
        'AC',
        'KM Dalam',
        'Kasur Springbed',
        'Meja Kerja',
        'Balkon Luar',
      ],
      status: _StatusKamar.terisi,
      catatan:
          'Kondisi Prima: Seluruh fasilitas dan kelistrikan berfungsi dengan normal.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_DataKamar> get _filteredKamar {
    final query = _searchController.text.trim().toLowerCase();
    return _daftarKamar.where((kamar) {
      if (_filterIndex == 1 && kamar.status != _StatusKamar.siapHuni) {
        return false;
      }
      if (_filterIndex == 2 && kamar.status != _StatusKamar.terisi) {
        return false;
      }
      if (_filterIndex == 3 && kamar.status != _StatusKamar.perbaikan) {
        return false;
      }
      if (query.isEmpty) return true;
      return kamar.kode.toLowerCase().contains(query) ||
          kamar.subjudul.toLowerCase().contains(query) ||
          kamar.fasilitas.any((f) => f.toLowerCase().contains(query));
    }).toList();
  }

  void _showSnackBar(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  void _konfirmasiHapus(_DataKamar kamar) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Kamar ${kamar.kode}?'),
        content: const Text(
          'Unit kamar ini akan dihapus dari daftar kamar KosAsih.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _daftarKamar.remove(kamar));
              _showSnackBar('Kamar ${kamar.kode} dihapus.');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kamarList = _filteredKamar;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 22,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar & Kelola Kamar',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'KosAsih Residence • Master Data',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showSnackBar(
                      'Form tambah kamar baru siap dihubungkan ke backend.',
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(
                      'Tambah',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1545C7),
                      foregroundColor: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    radius: 17,
                    backgroundColor: Color(0xFF1545C7),
                    child: Icon(Icons.person, size: 18, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Banner Status Ketersediaan Kamar
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: Color(0xFF4ADE80),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'STATUS KETERSEDIAAN KAMAR',
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 11,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Oktober 2026',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _buildSummaryTile(
                          icon: Icons.apartment,
                          title: 'Total Kamar',
                          value: '18',
                          valueColor: Colors.white,
                          subtitle: 'Unit KosAsih',
                          subtitleColor: Colors.white70,
                        ),
                        const SizedBox(width: 8),
                        _buildSummaryTile(
                          icon: Icons.people_outline,
                          title: 'Terisi',
                          value: '16',
                          valueColor: Colors.white,
                          subtitle: '88% Okupansi',
                          subtitleColor: const Color(0xFF4ADE80),
                        ),
                        const SizedBox(width: 8),
                        _buildSummaryTile(
                          icon: Icons.door_front_door_outlined,
                          title: 'Kosong',
                          value: '2',
                          valueColor: const Color(0xFF4ADE80),
                          subtitle: 'Siap Pasarkan',
                          subtitleColor: Colors.white70,
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
                        children: const [
                          Icon(
                            Icons.sync,
                            size: 14,
                            color: Color(0xFF4ADE80),
                          ),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Sinkronisasi data kamar aktif',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Search & Filter Button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Cari kode kamar (misal: A-04, B-09, AC)...',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF6B7280),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF1545C7),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: IconButton(
                      onPressed: () =>
                          _showSnackBar('Filter lanjutan kamar.'),
                      icon: const Icon(
                        Icons.tune,
                        size: 20,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'Semua',
                      count: 18,
                      selected: _filterIndex == 0,
                      onTap: () => setState(() => _filterIndex = 0),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Kosong',
                      count: 2,
                      dotColor: const Color(0xFF22C55E),
                      selected: _filterIndex == 1,
                      onTap: () => setState(() => _filterIndex = 1),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Terisi',
                      count: 16,
                      dotColor: const Color(0xFF1545C7),
                      selected: _filterIndex == 2,
                      onTap: () => setState(() => _filterIndex = 2),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Perbaikan',
                      count: 0,
                      dotColor: const Color(0xFFF59E0B),
                      selected: _filterIndex == 3,
                      onTap: () => setState(() => _filterIndex = 3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Header List Kamar
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text(
                              'Daftar Unit Kamar KosAsih ',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            Text(
                              '(18 Unit)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: const [
                            Icon(
                              Icons.sort,
                              size: 13,
                              color: Color(0xFF15803D),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Prioritas Kamar Kosong Teratas',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _showSnackBar('Urutan default aktif.'),
                      icon: const Icon(
                        Icons.sort,
                        size: 18,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Daftar Kartu Kamar
              ...kamarList.map(
                (kamar) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildRoomCard(kamar),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryTile({
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
    required String subtitle,
    required Color subtitleColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0x1FFFFFFF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: Colors.white70),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    Color? dotColor,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            if (dotColor != null) ...[
              Icon(
                Icons.circle,
                size: 8,
                color: selected ? Colors.white : dotColor,
              ),
              const SizedBox(width: 6),
            ],
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

  Widget _buildRoomCard(_DataKamar kamar) {
    final bool isKosong = kamar.status == _StatusKamar.siapHuni;

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
          // Header Kamar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isKosong
                      ? const Color(0xFF1545C7)
                      : const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  kamar.kode,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isKosong ? Colors.white : const Color(0xFF1545C7),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Kamar ${kamar.kode}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            kamar.lantai,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      kamar.subjudul,
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
                  color: isKosong
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFEEF4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isKosong ? '• SIAP HUNI' : '• TERISI',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isKosong
                        ? const Color(0xFF15803D)
                        : const Color(0xFF1545C7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tarif Sewa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  kamar.labelHarga,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      kamar.harga,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isKosong
                            ? const Color(0xFF1545C7)
                            : const Color(0xFF111827),
                      ),
                    ),
                    const Text(
                      ' / bulan',
                      style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Fasilitas
          if (isKosong) ...[
            const Text(
              'FASILITAS KAMAR',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: kamar.fasilitas
                .map(
                  (f) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _iconUntukFasilitas(f),
                          size: 12,
                          color: const Color(0xFF1545C7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          f,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),

          // Banner Status Fisik / Komplain
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kamar.adaKomplainAktif
                  ? const Color(0xFFFFF7ED)
                  : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: kamar.adaKomplainAktif
                    ? const Color(0xFFFED7AA)
                    : const Color(0xFFBBF7D0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      kamar.adaKomplainAktif
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      size: 16,
                      color: kamar.adaKomplainAktif
                          ? const Color(0xFFC2410C)
                          : const Color(0xFF15803D),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (kamar.adaKomplainAktif)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Text(
                                '1 Komplain Fasilitas Aktif',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFC2410C),
                                ),
                              ),
                            ),
                          Text(
                            kamar.catatan,
                            style: TextStyle(
                              fontSize: 11,
                              color: kamar.adaKomplainAktif
                                  ? const Color(0xFF7C2D12)
                                  : const Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (kamar.nomorTiket != null) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      kamar.nomorTiket!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC2410C),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tombol Aksi
          if (isKosong) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showSnackBar(
                  'Isi penghuni baru untuk Kamar ${kamar.kode}.',
                ),
                icon: const Icon(Icons.person_add_alt_1, size: 16),
                label: const Text(
                  '+ Isi Penghuni Baru',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1545C7),
                  foregroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showSnackBar('Edit detail Kamar ${kamar.kode}.'),
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text(
                      'Edit Kamar',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1545C7),
                      side: const BorderSide(color: Color(0xFFC7D7F8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _konfirmasiHapus(kamar),
                    icon: const Icon(Icons.delete_outline, size: 14),
                    label: const Text(
                      'Hapus',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (kamar.adaKomplainAktif) {
                        Navigator.of(context)
                            .pushNamed(KomplainFasilitasPage.routeName);
                      } else {
                        _showSnackBar('Detail fisik Kamar ${kamar.kode}.');
                      }
                    },
                    icon: Icon(
                      kamar.adaKomplainAktif
                          ? Icons.build_outlined
                          : Icons.info_outline,
                      size: 14,
                    ),
                    label: Text(
                      kamar.adaKomplainAktif ? 'Komplain' : 'Detail Fisik',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kamar.adaKomplainAktif
                          ? const Color(0xFFFFEDD5)
                          : const Color(0xFFF8FAFC),
                      foregroundColor: kamar.adaKomplainAktif
                          ? const Color(0xFFC2410C)
                          : const Color(0xFF374151),
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: BorderSide(
                        color: kamar.adaKomplainAktif
                            ? const Color(0xFFFED7AA)
                            : const Color(0xFFE5E7EB),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showSnackBar('Edit detail Kamar ${kamar.kode}.'),
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text(
                      'Edit Kamar',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1545C7),
                      side: const BorderSide(color: Color(0xFFC7D7F8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
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

  IconData _iconUntukFasilitas(String fasilitas) {
    final lower = fasilitas.toLowerCase();
    if (lower.contains('ac')) return Icons.ac_unit;
    if (lower.contains('km') || lower.contains('shower')) {
      return Icons.bathtub_outlined;
    }
    if (lower.contains('kasur')) return Icons.bed_outlined;
    if (lower.contains('wi-fi') || lower.contains('wifi')) return Icons.wifi;
    if (lower.contains('lemari')) return Icons.door_sliding_outlined;
    if (lower.contains('meja')) return Icons.desk_outlined;
    if (lower.contains('balkon')) return Icons.balcony_outlined;
    return Icons.check_circle_outline;
  }
}
