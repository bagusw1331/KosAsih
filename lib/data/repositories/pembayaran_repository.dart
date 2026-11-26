import 'dart:io';

import '../models/pembayaran_model.dart';
import '../services/fcm_service.dart';
import 'repository_exception.dart';

class PembayaranRepository {
  PembayaranRepository({FcmService? fcmService})
    : _fcmService = fcmService ?? FcmService.instance;

  final FcmService _fcmService;

  final List<PembayaranModel> _items = [
    const PembayaranModel(
      idPembayaran: 101,
      idKamar: 4,
      idUser: 12,
      periodePembayaran: 'Oktober 2026',
      tenggatPembayaran: '2026-10-13',
      nominalPembayaran: 1200000,
      biayaTamuPembayaran: 50000,
      dendaPembayaran: 40000,
      buktiPembayaran: 'bukti_transfer_bca_a04.jpg',
      statusPembayaran: 'menunggu_verifikasi',
      kodeKamar: 'A-04',
      namaPenghuni: 'Bagus Wihandono',
      infoKamar: 'Kamar Utama AC • Lt 1',
      metodePembayaran: 'Transfer Bank BCA',
      hariTerlambat: 2,
    ),
    const PembayaranModel(
      idPembayaran: 102,
      idKamar: 5,
      idUser: 15,
      periodePembayaran: 'Oktober 2026',
      tenggatPembayaran: '2026-10-15',
      nominalPembayaran: 1200000,
      biayaTamuPembayaran: 0,
      dendaPembayaran: 0,
      buktiPembayaran: 'bukti_transfer_mandiri_b01.jpg',
      statusPembayaran: 'menunggu_verifikasi',
      kodeKamar: 'B-01',
      namaPenghuni: 'Raka Pratama',
      infoKamar: 'Lantai 2 • Balkon Luar',
      metodePembayaran: 'Transfer Bank Mandiri',
      hariTerlambat: 0,
    ),
    const PembayaranModel(
      idPembayaran: 103,
      idKamar: 2,
      idUser: 10,
      periodePembayaran: 'Oktober 2026',
      tenggatPembayaran: '2026-10-15',
      nominalPembayaran: 1200000,
      biayaTamuPembayaran: 0,
      dendaPembayaran: 0,
      buktiPembayaran: 'qris_oktober_a02.png',
      kuitansiPembayaran: 'e_kuitansi_a02_okt2026.pdf',
      statusPembayaran: 'lunas',
      tglLunasPembayaran: '12 Okt 2026 • 14:20 WIB',
      kodeKamar: 'A-02',
      namaPenghuni: 'Nadia Putri',
      infoKamar: 'Lantai 1 • Kamar Standar AC',
      metodePembayaran: 'QRIS Instan',
      hariTerlambat: 0,
    ),
  ];

  Future<List<PembayaranModel>> fetchDaftarPembayaran() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List<PembayaranModel>.unmodifiable(_items);
  }

  /// Penghuni mengunggah bukti transfer/QRIS (belum_bayar -> menunggu_verifikasi)
  Future<PembayaranModel> uploadBuktiPembayaran({
    required int idPembayaran,
    required File fileBukti,
    required String metodePembayaran,
  }) async {
    FileUploadValidator.validate(
      fileBukti,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf'],
    );

    await Future<void>.delayed(const Duration(milliseconds: 400));
    final fileName = fileBukti.path.split(Platform.pathSeparator).last;
    final index = _items.indexWhere((e) => e.idPembayaran == idPembayaran);

    if (index == -1) {
      final baru = PembayaranModel(
        idPembayaran: idPembayaran,
        idKamar: 4,
        idUser: 12,
        periodePembayaran: 'Oktober 2026',
        tenggatPembayaran: '2026-10-15',
        nominalPembayaran: 1200000,
        biayaTamuPembayaran: 50000,
        dendaPembayaran: 40000,
        buktiPembayaran: fileName,
        statusPembayaran: 'menunggu_verifikasi',
        kodeKamar: 'A-04',
        namaPenghuni: 'Bagus Wihandono',
        infoKamar: 'Kamar Utama AC • Lt 1',
        metodePembayaran: metodePembayaran,
        hariTerlambat: 2,
      );
      _items.insert(0, baru);
      return baru;
    }

    final updated = _items[index].copyWith(
      buktiPembayaran: fileName,
      metodePembayaran: metodePembayaran,
      statusPembayaran: 'menunggu_verifikasi',
      alasanPenolakan: null,
    );
    _items[index] = updated;
    return updated;
  }

  /// Pemilik menyetujui bukti bayar (menunggu_verifikasi -> lunas + E-Kuitansi)
  Future<PembayaranModel> verifikasiPembayaran(int idPembayaran) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final index = _items.indexWhere((e) => e.idPembayaran == idPembayaran);
    if (index == -1) {
      throw const RepositoryException('Data pembayaran tidak ditemukan.');
    }

    final current = _items[index];
    final updated = current.copyWith(
      statusPembayaran: 'lunas',
      tglLunasPembayaran: 'Hari ini • WIB',
      kuitansiPembayaran:
          'e_kuitansi_${current.kodeKamar.toLowerCase()}_${current.idPembayaran}.pdf',
    );
    _items[index] = updated;

    await _fcmService.sendPushNotification(
      title: 'Pembayaran Diverifikasi (Lunas)',
      body:
          'Pembayaran kamar ${current.kodeKamar} telah disetujui. E-Kuitansi PDF siap diunduh.',
      type: 'pembayaran',
      targetId: current.idPembayaran,
    );

    return updated;
  }

  /// Pemilik menolak bukti bayar disertai alasan (menunggu_verifikasi -> belum_bayar)
  Future<PembayaranModel> tolakPembayaran({
    required int idPembayaran,
    required String alasanPenolakan,
  }) async {
    if (alasanPenolakan.trim().isEmpty) {
      throw const RepositoryException('Alasan penolakan wajib diisi.');
    }

    await Future<void>.delayed(const Duration(milliseconds: 350));
    final index = _items.indexWhere((e) => e.idPembayaran == idPembayaran);
    if (index == -1) {
      throw const RepositoryException('Data pembayaran tidak ditemukan.');
    }

    final current = _items[index];
    final updated = current.copyWith(
      statusPembayaran: 'belum_bayar',
      alasanPenolakan: alasanPenolakan.trim(),
    );
    _items[index] = updated;

    await _fcmService.sendPushNotification(
      title: 'Bukti Pembayaran Ditolak',
      body:
          'Bukti kamar ${current.kodeKamar} ditolak: ${alasanPenolakan.trim()}. Silakan unggah ulang.',
      type: 'pembayaran',
      targetId: current.idPembayaran,
    );

    return updated;
  }
}
