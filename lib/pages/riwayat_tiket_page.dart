import 'package:flutter/material.dart';

import '../widgets/kosasih_bottom_nav.dart';

/// Riwayat dan progres tiket aduan penghuni.
class RiwayatTiketPage extends StatelessWidget {
  const RiwayatTiketPage({super.key});

  static const String routeName = '/riwayat-tiket';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Riwayat & Progres Tiket'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Filter tiket belum tersedia.')),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.door_front_door_outlined,
                  size: 14,
                  color: Color(0xFF1D4ED8),
                ),
                SizedBox(width: 4),
                Text(
                  'Laporan / Aduan  •  Kamar A-04 • Bagus Wihandono',
                  style: TextStyle(fontSize: 11, color: Color(0xFF475569)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ticketCard(
              nomor: '#TKT-014',
              judul: 'AC kurang dingin & menetes',
              status: 'SEDANG DIPERBAIKI',
              statusColor: const Color(0xFF1D4ED8),
              kategori: 'Pendingin Udara (AC)',
              waktu: '14 Oktober 2026, 09.30 WIB',
              catatan: 'Teknisi AC langganan dijadwalkan tiba hari ini pukul 14.00 WIB. Mohon kunci kamar disiapkan jika penghuni sedang keluar.',
              aktif: true,
            ),
            const SizedBox(height: 12),
            _ticketCard(
              nomor: '#TKT-009',
              judul: 'Keran kamar mandi bocor',
              status: 'SELESAI',
              statusColor: const Color(0xFF15803D),
              kategori: 'Air & Sanitasi',
              waktu: 'Diselesaikan pada 03 Okt 2026, 11.20 WIB',
              catatan: 'Solusi: Karet seal keran telah diganti baru oleh pengelola dan dites normal.',
              aktif: false,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const PenghuniBottomNav(
        currentIndex: 2,
        allowReselectCurrent: true,
      ),
    );
  }

  Widget _ticketCard({
    required String nomor,
    required String judul,
    required String status,
    required Color statusColor,
    required String kategori,
    required String waktu,
    required String catatan,
    required bool aktif,
  }) {
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
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.handyman,
                  color: Color(0xFF1D4ED8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      judul,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$kategori  •  $waktu',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$nomor  •  $status',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (aktif) ...[
            Row(
              children: [
                _step('Diterima', true, const Color(0xFF15803D)),
                Expanded(
                  child: Container(height: 2, color: const Color(0xFF1D4ED8)),
                ),
                _step('Pengerjaan', true, const Color(0xFF1D4ED8)),
                Expanded(
                  child: Container(height: 2, color: const Color(0xFFE2E8F0)),
                ),
                _step('Selesai', false, const Color(0xFF94A3B8)),
              ],
            ),
            const SizedBox(height: 14),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: aktif ? const Color(0xFFEFF6FF) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              aktif ? 'Catatan Pengelola Kos: $catatan' : catatan,
              style: const TextStyle(
                fontSize: 11,
                height: 1.4,
                color: Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(String label, bool done, Color color) {
    return Column(
      children: [
        Icon(
          done ? Icons.check_circle : Icons.circle_outlined,
          size: 22,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
