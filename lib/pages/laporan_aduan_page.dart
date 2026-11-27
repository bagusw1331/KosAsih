import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/ticket_fcm_bloc/ticket_fcm_bloc.dart';
import '../logic/ticket_fcm_bloc/ticket_fcm_event.dart';
import '../logic/ticket_fcm_bloc/ticket_fcm_state.dart';
import 'riwayat_tiket_page.dart';

class LaporanAduanPage extends StatefulWidget {
  const LaporanAduanPage({super.key});

  /// Nama route, dipakai oleh `main.dart`.
  static const String routeName = '/laporan-aduan';

  @override
  State<LaporanAduanPage> createState() => _LaporanAduanPageState();
}

class _LaporanAduanPageState extends State<LaporanAduanPage> {
  static const int _maxFileBytes = 5 * 1024 * 1024; // 5 MB

  static const List<String> _kategoriList = [
    'Pendingin Udara (AC)',
    'Air & Sanitasi',
    'Listrik & Penerangan',
    'Kunci & Pintu',
    'Jaringan WiFi',
    'Fasilitas Umum',
  ];

  String _selectedKategori = 'Pendingin Udara (AC)';
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  File? _fotoFile;
  String? _fotoName;
  int? _fotoSizeBytes;
  String? _formError;

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pilihFotoKerusakan() async {
    setState(() => _formError = null);

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png'],
      );
      if (files.isEmpty) return;

      final picked = files.single;
      if (picked.path == null || picked.path!.trim().isEmpty) {
        setState(() => _formError = 'Lokasi foto tidak dapat dibaca.');
        return;
      }

      final file = File(picked.path!);
      final size = await file.length();
      if (size > _maxFileBytes) {
        setState(
          () => _formError = 'Ukuran foto melebihi batas maksimal 5 MB.',
        );
        return;
      }

      setState(() {
        _fotoFile = file;
        _fotoName = picked.name;
        _fotoSizeBytes = size;
        _formError = null;
      });
    } catch (_) {
      setState(() => _formError = 'Gagal membuka pemilih gambar.');
    }
  }

  void _hapusFotoKerusakan() {
    setState(() {
      _fotoFile = null;
      _fotoName = null;
      _fotoSizeBytes = null;
      _formError = null;
    });
  }

  String _formatUkuranFile(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _kirimLaporan() {
    final judul = _judulController.text.trim();
    final deskripsi = _deskripsiController.text.trim();

    if (judul.isEmpty || deskripsi.isEmpty) {
      setState(() {
        _formError = 'Judul keluhan dan deskripsi kerusakan wajib diisi.';
      });
      return;
    }

    setState(() => _formError = null);

    context.read<TicketFcmBloc>().add(
      TicketCreated(
        idUser: 2,
        idKamar: 4,
        kodeKamar: 'A-04',
        namaPenghuni: 'Bagus Wihandono',
        kategoriFasilitas: _selectedKategori,
        judulKomplain: judul,
        deskripsiKomplain: deskripsi,
        fotoKerusakan: _fotoFile,
      ),
    );

    _judulController.clear();
    _deskripsiController.clear();
    _hapusFotoKerusakan();
  }

  @override
  Widget build(BuildContext context) {
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
        final isSubmitting = state is TicketFcmLoading;
        final jumlahTiket = state is TicketFcmLoaded
            ? state.daftarKomplain.length
            : 0;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KosAsih',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Aduan',
                      style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Penghuni',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: Color(0xFF1E293B),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(RiwayatTiketPage.routeName);
                },
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Laporan / Aduan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(
                        Icons.door_front_door_outlined,
                        size: 14,
                        color: Color(0xFF1D4ED8),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Kamar A-04 • Bagus Wihandono',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475563),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Form Buat Laporan Baru Card
                  Container(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEFF6FF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add_task,
                                    color: Color(0xFF1D4ED8),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Buat Laporan Baru',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E40AF),
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
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Kamar A-04',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF475563),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        _buildLabel('Kategori Fasilitas *'),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedKategori,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.build_circle_outlined,
                              size: 18,
                              color: Color(0xFF1D4ED8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF1F5F9)
                                .withValues(alpha: 0.5),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                          items: _kategoriList
                              .map(
                                (kat) => DropdownMenuItem(
                                  value: kat,
                                  child: Text(kat),
                                ),
                              )
                              .toList(),
                          onChanged: isSubmitting
                              ? null
                              : (val) {
                                  if (val != null) {
                                    setState(() => _selectedKategori = val);
                                  }
                                },
                        ),
                        const SizedBox(height: 14),

                        _buildLabel('Judul Keluhan *'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _judulController,
                          enabled: !isSubmitting,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Contoh: AC kurang dingin dan menetes',
                            hintStyle: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                            prefixIcon: const Icon(
                              Icons.edit_note,
                              size: 18,
                              color: Color(0xFF64748B),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF1F5F9)
                                .withValues(alpha: 0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        _buildLabel('Deskripsi Detail Kerusakan *'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _deskripsiController,
                          enabled: !isSubmitting,
                          maxLines: 3,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: Color(0xFF334155),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Jelaskan kondisi kerusakan dan sejak kapan terjadi...',
                            hintStyle: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF1F5F9)
                                .withValues(alpha: 0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLabel('Foto Bukti Kerusakan Fisik'),
                            Text(
                              _fotoFile != null
                                  ? '1 Foto Terpilih'
                                  : 'Opsional (Maks. 5MB)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _fotoFile != null
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9)
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              if (_fotoFile != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _fotoFile!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _fotoName ?? 'foto_bukti.jpg',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                Text(
                                                  '${_formatUkuranFile(_fotoSizeBytes ?? 0)}  • ',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                                const Text(
                                                  'Siap Unggah',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF16A34A),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: isSubmitting
                                            ? null
                                            : _pilihFotoKerusakan,
                                        tooltip: 'Ganti foto',
                                        icon: const Icon(
                                          Icons.refresh,
                                          size: 16,
                                          color: Color(0xFF1D4ED8),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: isSubmitting
                                            ? null
                                            : _hapusFotoKerusakan,
                                        tooltip: 'Hapus foto',
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          size: 16,
                                          color: Color(0xFFDC2626),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                              InkWell(
                                onTap: isSubmitting
                                    ? null
                                    : _pilihFotoKerusakan,
                                borderRadius: BorderRadius.circular(10),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        size: 16,
                                        color: Color(0xFF1D4ED8),
                                      ),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Ketuk untuk pilih foto bukti (Format JPG/PNG maks. 5MB)',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1D4ED8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_formError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _formError!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: isSubmitting ? null : _kirimLaporan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF003399),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: Text(
                              isSubmitting ? 'MENGIRIM...' : 'KIRIM',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: OutlinedButton(
                            onPressed: () =>
                                Navigator.of(context)
                                    .pushNamed(RiwayatTiketPage.routeName),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFDBEAFE)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.history,
                                  size: 16,
                                  color: Color(0xFF1D4ED8),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Lihat Riwayat Aduan Saya',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1D4ED8),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDBEAFE),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$jumlahTiket Tiket',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1D4ED8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 2,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF1D4ED8),
            unselectedItemColor: const Color(0xFF64748B),
            selectedFontSize: 11,
            unselectedFontSize: 11,
            onTap: (index) {
              if (index == 0) {
                Navigator.of(context).pushReplacementNamed('/beranda-penghuni');
              } else if (index == 1) {
                Navigator.of(context).pushReplacementNamed('/rincian-tagihan');
              } else if (index == 3) {
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

  static Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Color(0xFF334155),
      ),
    );
  }
}
