import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/pembayaran_model.dart';
import '../logic/payment_verify_bloc/payment_verify_bloc.dart';
import '../logic/payment_verify_bloc/payment_verify_event.dart';
import '../logic/payment_verify_bloc/payment_verify_state.dart';

import '../widgets/kosasih_bottom_nav.dart';

/// Halaman pembayaran QRIS.
class PembayaranQrisPage extends StatefulWidget {
  const PembayaranQrisPage({super.key});

  static const String routeName = '/pembayaran-qris';

  @override
  State<PembayaranQrisPage> createState() => _PembayaranQrisPageState();
}

class _PembayaranQrisPageState extends State<PembayaranQrisPage> {
  static const int _maxFileBytes = 5 * 1024 * 1024; // 5 MB

  File? _selectedFile;
  String? _fileName;
  int? _fileSizeBytes;
  String? _fileError;

  void _aksi(BuildContext context, String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _pilihFileBukti() async {
    setState(() => _fileError = null);

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
      );
      if (files.isEmpty) return;

      final picked = files.single;
      if (picked.path == null || picked.path!.trim().isEmpty) {
        setState(() => _fileError = 'Lokasi file tidak dapat dibaca.');
        return;
      }

      final file = File(picked.path!);
      final size = await file.length();
      if (size > _maxFileBytes) {
        setState(() => _fileError = 'Ukuran file melebihi batas maksimal 5 MB.');
        return;
      }

      setState(() {
        _selectedFile = file;
        _fileName = picked.name;
        _fileSizeBytes = size;
        _fileError = null;
      });
    } catch (_) {
      setState(() => _fileError = 'Gagal membuka pemilih file.');
    }
  }

  void _hapusFileBukti() {
    setState(() {
      _selectedFile = null;
      _fileName = null;
      _fileSizeBytes = null;
      _fileError = null;
    });
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

  String _formatUkuranFile(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _kirimBukti(BuildContext context, PembayaranModel? targetTagihan) {
    if (_selectedFile == null) {
      setState(() {
        _fileError = 'Wajib melampirkan screenshot bukti QRIS terlebih dahulu.';
      });
      _aksi(context, 'Pilih screenshot bukti QRIS terlebih dahulu.');
      return;
    }

    final idTagihan = targetTagihan?.idPembayaran ?? 1;
    context.read<PaymentVerifyBloc>().add(
          PaymentProofSubmitted(
            idPembayaran: idTagihan,
            fileBukti: _selectedFile!,
            metodePembayaran: 'QRIS',
          ),
        );
  }

  void _lihatKwitansi(BuildContext context, PembayaranModel tagihan) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'E-Kwitansi Resmi (Lunas)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No. Kwitansi: ${tagihan.kuitansiPembayaran ?? 'KWT-${tagihan.idPembayaran}'}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF15803D),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Penghuni: ${tagihan.namaPenghuni} (${tagihan.kodeKamar})',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Periode: ${tagihan.periodePembayaran}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Total Lunas: ${_formatRupiah(tagihan.totalTagihan)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D4ED8),
              ),
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
    return BlocConsumer<PaymentVerifyBloc, PaymentVerifyState>(
      listener: (context, state) {
        if (state is PaymentVerifyLoaded && state.actionMessage != null) {
          _aksi(context, state.actionMessage!);
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
        PembayaranModel? tagihan;
        if (state is PaymentVerifyLoaded && state.daftarPembayaran.isNotEmpty) {
          tagihan = state.daftarPembayaran.firstWhere(
            (e) => e.metodePembayaran.toLowerCase().contains('qris'),
            orElse: () => state.daftarPembayaran.first,
          );
        }

        final isSubmitting = state is PaymentVerifyLoading;
        final isLunas = tagihan?.statusPembayaran == 'lunas';
        final nominalText = tagihan != null
            ? _formatRupiah(tagihan.totalTagihan)
            : 'Rp 1.290.000';
        final headerSubtitle = tagihan != null
            ? 'Kamar ${tagihan.kodeKamar} • ${tagihan.namaPenghuni}'
            : 'Kamar A-04 • Bagus Wihandono';

        final displayFileName = _fileName ?? 'Belum ada screenshot dipilih';
        final displayFileMeta = _selectedFile != null && _fileSizeBytes != null
            ? '${_formatUkuranFile(_fileSizeBytes!)}  •  ✓ Terlampir'
            : 'Wajib pilih file JPG, PNG, atau PDF (Maks. 5 MB)';

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pembayaran',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  headerSubtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'QRIS',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          Text(
                            'GPN  •  NATIONAL STANDARD',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'PT KOSASIH SEJAHTERA UTAMA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'NMID : ID10260639281928',
                        style:
                            TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '◷  Berlaku hingga 15:00',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC2410C),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 210,
                        height: 210,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFF0F172A),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 13,
                              ),
                              itemCount: 169,
                              itemBuilder: (_, index) {
                                final int row = index ~/ 13;
                                final int col = index % 13;
                                final bool finder = (row < 5 && col < 5) ||
                                    (row < 5 && col > 7) ||
                                    (row > 7 && col < 5);
                                final bool dark = finder
                                    ? ((row == 0 ||
                                            row == 4 ||
                                            col == 0 ||
                                            col == 4) ||
                                        (row >= 1 &&
                                            row <= 3 &&
                                            col >= 1 &&
                                            col <= 3))
                                    : (index * 17 + row * 3 + col) % 5 < 2;
                                return Container(
                                  margin: const EdgeInsets.all(1),
                                  color: dark ? Colors.black : Colors.white,
                                );
                              },
                            ),
                            Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1D4ED8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.home,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'TOTAL TAGIHAN OTOMATIS',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        nominalText,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '✓  Nominal terisi otomatis saat discan',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _aksi(context, 'QR disiapkan untuk diunduh.'),
                              icon: const Icon(Icons.download, size: 15),
                              label: const Text(
                                'Unduh QR',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _aksi(context, 'QRIS siap dibagikan.'),
                              icon: const Icon(Icons.share, size: 15),
                              label: const Text(
                                'Bagikan QRIS',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Text(
                      'Unggah Bukti Transaksi QRIS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      ' *',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Wajib diisi',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Setelah scan dan transfer melalui e-wallet atau m-banking, simpan lalu lampirkan screenshot bukti pembayaran.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: isSubmitting ? null : _pilihFileBukti,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF93C5FD)),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 27,
                          color: Color(0xFF1D4ED8),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Ketuk untuk unggah screenshot QRIS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Format file JPG, PNG, atau PDF (Maks. 5MB)',
                          style:
                              TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_fileError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _fileError!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 16,
                        color: Color(0xFF1D4ED8),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayFileName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displayFileMeta,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: _selectedFile != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _selectedFile != null
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: isSubmitting || _selectedFile == null
                            ? null
                            : _hapusFileBukti,
                        tooltip: 'Hapus file',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 17,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: isSubmitting
                        ? null
                        : () => _kirimBukti(context, tagihan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D4ED8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: Text(
                      isSubmitting ? 'MENGIRIM...' : 'KIRIM BUKTI PEMBAYARAN',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: isLunas && tagihan != null
                        ? () => _lihatKwitansi(context, tagihan!)
                        : null,
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                    label: const Text(
                      'UNDUH E-KWITANSI PDF (LUNAS)',
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '* E-Kwitansi resmi baru tersedia sesaat setelah pembayaran terverifikasi bendahara.',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
<<<<<<< HEAD
          ),
        );
      },
=======
            const SizedBox(height: 8),
            const Text(
              '* E-Kwitansi resmi baru tersedia sesaat setelah pembayaran terverifikasi bendahara.',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const PenghuniBottomNav(
        currentIndex: 1,
        allowReselectCurrent: true,
      ),
>>>>>>> 3794f9c95113a0379f74cdcbede3f9935190c627
    );
  }
}