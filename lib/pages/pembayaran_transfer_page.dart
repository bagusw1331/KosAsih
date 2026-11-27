import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/pembayaran_model.dart';
import '../logic/payment_verify_bloc/payment_verify_bloc.dart';
import '../logic/payment_verify_bloc/payment_verify_event.dart';
import '../logic/payment_verify_bloc/payment_verify_state.dart';

import '../widgets/kosasih_bottom_nav.dart';

/// Halaman pembayaran via transfer bank (BCA).
class PembayaranTransferPage extends StatefulWidget {
  const PembayaranTransferPage({super.key});

  static const String routeName = '/pembayaran-transfer';

  @override
  State<PembayaranTransferPage> createState() => _PembayaranTransferPageState();
}

class _PembayaranTransferPageState extends State<PembayaranTransferPage> {
  static const String _nomorRekening = '1234 5678 90';
  static const int _maxFileBytes = 5 * 1024 * 1024; // 5 MB

  File? _selectedFile;
  String? _fileName;
  int? _fileSizeBytes;
  String? _fileError;

  Future<void> _salinRekening(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: '1234567890'));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Nomor rekening disalin.')));
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
        setState(() {
          _fileError = 'Lokasi file tidak dapat dibaca.';
        });
        return;
      }

      final file = File(picked.path!);
      final size = await file.length();
      if (size > _maxFileBytes) {
        setState(() {
          _fileError = 'Ukuran file melebihi batas maksimal 5 MB.';
        });
        return;
      }

      setState(() {
        _selectedFile = file;
        _fileName = picked.name;
        _fileSizeBytes = size;
        _fileError = null;
      });
    } catch (_) {
      setState(() {
        _fileError = 'Gagal membuka pemilih file.';
      });
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
    return '${nominal < 0 ? '-' : ''}Rp$buffer';
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
        _fileError = 'Wajib melampirkan bukti struk transfer terlebih dahulu.';
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Pilih file bukti struk transfer terlebih dahulu.'),
          ),
        );
      return;
    }

    final idTagihan = targetTagihan?.idPembayaran ?? 1;
    context.read<PaymentVerifyBloc>().add(
          PaymentProofSubmitted(
            idPembayaran: idTagihan,
            fileBukti: _selectedFile!,
            metodePembayaran: 'Transfer Bank BCA',
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
        PembayaranModel? tagihan;
        if (state is PaymentVerifyLoaded && state.daftarPembayaran.isNotEmpty) {
          tagihan = state.daftarPembayaran.firstWhere(
            (e) => e.metodePembayaran.toLowerCase().contains('bca'),
            orElse: () => state.daftarPembayaran.first,
          );
        }

        final isSubmitting = state is PaymentVerifyLoading;
        final isLunas = tagihan?.statusPembayaran == 'lunas';
        final nominalText = tagihan != null
            ? _formatRupiah(tagihan.totalTagihan)
            : 'Rp1.290.000';
        final headerSubtitle = tagihan != null
            ? 'Kamar ${tagihan.kodeKamar} • ${tagihan.namaPenghuni}'
            : 'Kamar A-04 • Bagus Wihandono';
        final periodeText = tagihan != null
            ? 'Periode ${tagihan.periodePembayaran}'
            : 'Periode Okt 2026';

        final displayFileName = _fileName ?? 'Belum ada file dipilih';
        final displayFileMeta = _selectedFile != null && _fileSizeBytes != null
            ? '${_formatUkuranFile(_fileSizeBytes!)}  •  Terlampir'
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E40AF), Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL YANG HARUS DITRANSFER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        nominalText,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text(
                            'BATAS WAKTU',
                            style:
                                TextStyle(fontSize: 9, color: Colors.white70),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x33FFFFFF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tagihan?.tenggatPembayaran.isNotEmpty == true
                                  ? tagihan!.tenggatPembayaran
                                  : '23:59:45',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '#INV-${tagihan?.idPembayaran ?? 202610}',
                            style: const TextStyle(
                              fontSize: 9,
                              fontFamily: 'monospace',
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        periodeText,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
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
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'BCA',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Transfer ke Rekening BCA',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'a.n. PT KosAsih Sejahtera Utama',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'NOMOR REKENING',
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 0.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              _nomorRekening,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _salinRekening(context),
                            icon: const Icon(Icons.copy, size: 14),
                            label: const Text(
                              'Salin',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
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
                      'Unggah Bukti Struk Transfer',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '*',
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
                      border: Border.all(color: const Color(0xFFDBEAFE)),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 26,
                          color: Color(0xFF1D4ED8),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Ketuk untuk unggah foto struk',
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
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displayFileMeta,
                              style: TextStyle(
                                fontSize: 10,
                                color: _selectedFile != null
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF64748B),
                                fontWeight: _selectedFile != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: isSubmitting ? null : _pilihFileBukti,
                        tooltip: 'Ganti file',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.refresh,
                          size: 16,
                          color: Color(0xFF1D4ED8),
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
                          size: 16,
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
                        letterSpacing: 0.5,
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
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
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
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                label: const Text(
                  'UNDUH E-KWITANSI PDF (LUNAS)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
      ),
      bottomNavigationBar: const PenghuniBottomNav(
        currentIndex: 1,
        allowReselectCurrent: true,
      ),
>>>>>>> 3794f9c95113a0379f74cdcbede3f9935190c627
    );
  }
}