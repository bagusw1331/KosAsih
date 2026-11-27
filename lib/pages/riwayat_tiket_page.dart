import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/komplain_model.dart';
import '../logic/ticket_fcm_bloc/ticket_fcm_bloc.dart';
import '../logic/ticket_fcm_bloc/ticket_fcm_event.dart';
import '../logic/ticket_fcm_bloc/ticket_fcm_state.dart';
import '../widgets/kosasih_bottom_nav.dart';

/// Riwayat dan progres tiket aduan penghuni.
class RiwayatTiketPage extends StatefulWidget {
  const RiwayatTiketPage({super.key});

  static const String routeName = '/riwayat-tiket';

  @override
  State<RiwayatTiketPage> createState() => _RiwayatTiketPageState();
}

class _RiwayatTiketPageState extends State<RiwayatTiketPage> {
  String _statusFilter = 'semua';

  @override
  void initState() {
    super.initState();
    context.read<TicketFcmBloc>().add(const TicketRequested());
  }

  void _pilihFilter() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Filter Status Tiket',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('Semua Tiket'),
              trailing: _statusFilter == 'semua'
                  ? const Icon(Icons.check, color: Color(0xFF1D4ED8))
                  : null,
              onTap: () {
                setState(() => _statusFilter = 'semua');
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              title: const Text('Menunggu Tinjauan'),
              trailing: _statusFilter == 'menunggu'
                  ? const Icon(Icons.check, color: Color(0xFF1D4ED8))
                  : null,
              onTap: () {
                setState(() => _statusFilter = 'menunggu');
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              title: const Text('Sedang Diperbaiki'),
              trailing: _statusFilter == 'sedang_diperbaiki'
                  ? const Icon(Icons.check, color: Color(0xFF1D4ED8))
                  : null,
              onTap: () {
                setState(() => _statusFilter = 'sedang_diperbaiki');
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              title: const Text('Selesai'),
              trailing: _statusFilter == 'selesai'
                  ? const Icon(Icons.check, color: Color(0xFF1D4ED8))
                  : null,
              onTap: () {
                setState(() => _statusFilter = 'selesai');
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketFcmBloc, TicketFcmState>(
      builder: (context, state) {
        final isLoading =
            state is TicketFcmInitial || state is TicketFcmLoading;
        final semua = state is TicketFcmLoaded
            ? state.daftarKomplain
            : const <KomplainModel>[];
        final daftarTiket = _statusFilter == 'semua'
            ? semua
            : semua.where((k) => k.statusKomplain == _statusFilter).toList();

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
              IconButton(icon: const Icon(Icons.tune), onPressed: _pilihFilter),
            ],
          ),
          body: isLoading && semua.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<TicketFcmBloc>().add(const TicketRequested());
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.door_front_door_outlined,
                              size: 14,
                              color: Color(0xFF1D4ED8),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Laporan / Aduan  •  Kamar A-04 • Bagus Wihandono',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (daftarTiket.isEmpty)
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
                                'Belum ada tiket aduan pada filter ini.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          )
                        else
                          ...daftarTiket.map((tiket) {
                            final isMenunggu =
                                tiket.statusKomplain == 'menunggu';
                            final isDikerjakan =
                                tiket.statusKomplain == 'sedang_diperbaiki';
                            final aktif = isMenunggu || isDikerjakan;
                            final statusText = isMenunggu
                                ? 'MENUNGGU TINJAUAN'
                                : isDikerjakan
                                ? 'SEDANG DIPERBAIKI'
                                : 'SELESAI';
                            final statusColor = isMenunggu
                                ? const Color(0xFFEA580C)
                                : isDikerjakan
                                ? const Color(0xFF1D4ED8)
                                : const Color(0xFF15803D);
                            final catatanText =
                                (tiket.catatanKomplain != null &&
                                    tiket.catatanKomplain!.isNotEmpty)
                                ? tiket.catatanKomplain!
                                : aktif
                                ? 'Laporan telah diterima dan sedang ditinjau oleh pengelola kos.'
                                : 'Perbaikan telah diselesaikan oleh pengelola kos.';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ticketCard(
                                nomor: tiket.kodeTiket,
                                judul: tiket.judulKomplain,
                                status: statusText,
                                statusColor: statusColor,
                                kategori: tiket.kategoriFasilitas,
                                waktu: tiket.tglKomplain,
                                catatan: catatanText,
                                aktif: aktif,
                                sedangDikerjakan: isDikerjakan,
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 2,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF1D4ED8),
            unselectedItemColor: const Color(0xFF64748B),
            onTap: (index) {
              if (index == 0) {
                Navigator.of(context).pushReplacementNamed('/beranda-penghuni');
              }
              if (index == 1) {
                Navigator.of(context).pushReplacementNamed('/rincian-tagihan');
              }
              if (index == 3) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Panduan belum tersedia.')),
                );
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_outlined),
                label: 'Tagihan',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Aduan'),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                label: 'Panduan',
              ),
            ],
          ),
        );
      },
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
    required bool sedangDikerjakan,
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
                  child: Container(
                    height: 2,
                    color: sedangDikerjakan
                        ? const Color(0xFF1D4ED8)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                _step(
                  'Pengerjaan',
                  sedangDikerjakan,
                  sedangDikerjakan
                      ? const Color(0xFF1D4ED8)
                      : const Color(0xFF94A3B8),
                ),
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
