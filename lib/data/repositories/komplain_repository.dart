import 'dart:io';

import '../models/komplain_model.dart';
import '../services/fcm_service.dart';
import 'repository_exception.dart';

class KomplainRepository {
  KomplainRepository({FcmService? fcmService})
    : _fcmService = fcmService ?? FcmService.instance;

  final FcmService _fcmService;

  final List<KomplainModel> _items = [
    const KomplainModel(
      idKomplain: 15,
      idUser: 12,
      idKamar: 4,
      judulKomplain: 'AC Tidak Dingin & Menetes',
      deskripsiKomplain:
          'Sejak semalam AC hanya mengeluarkan angin biasa dan pipa indoor meneteskan air cukup deras ke lantai kamar.',
      fotoKomplain: 'bukti_ac_bocor_kamar_a04.jpg',
      catatanKomplain:
          'Teknisi AC CV Sentosa Dingin dijadwalkan datang hari ini pukul 14.00 WIB.',
      statusKomplain: 'menunggu',
      tglKomplain: '15 Okt 2026, 07:30 WIB',
      kodeKamar: 'A-04',
      namaPenghuni: 'Bagus Wihandono',
      kategoriFasilitas: 'Pendingin Udara (AC)',
      prioritas: 'Prioritas Tinggi',
    ),
    const KomplainModel(
      idKomplain: 9,
      idUser: 18,
      idKamar: 8,
      judulKomplain: 'Keran Wastafel Bocor & Patah Tuas',
      deskripsiKomplain: 'Tuas keran wastafel kamar mandi patah saat diputar.',
      catatanKomplain:
          'Seal keran diganti unit stainless baru, instalasi pipa diperkuat, dan debit air kini normal kembali.',
      statusKomplain: 'selesai',
      tglKomplain: '10 Okt 2026, 16:45 WIB',
      kodeKamar: 'B-02',
      namaPenghuni: 'Raka Pratama',
      kategoriFasilitas: 'Air & Sanitasi',
      prioritas: 'Normal',
    ),
  ];

  Future<List<KomplainModel>> fetchDaftarKomplain() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List<KomplainModel>.unmodifiable(_items);
  }

  Future<KomplainModel> buatKomplain({
    required int idUser,
    required int idKamar,
    required String kodeKamar,
    required String namaPenghuni,
    required String kategoriFasilitas,
    required String judulKomplain,
    required String deskripsiKomplain,
    File? fotoKerusakan,
  }) async {
    if (judulKomplain.trim().isEmpty || deskripsiKomplain.trim().isEmpty) {
      throw const RepositoryException(
        'Judul dan deskripsi keluhan wajib diisi.',
      );
    }

    String? namaFoto;
    if (fotoKerusakan != null) {
      FileUploadValidator.validate(
        fotoKerusakan,
        allowedExtensions: const ['jpg', 'jpeg', 'png'],
      );
      namaFoto = fotoKerusakan.path.split(Platform.pathSeparator).last;
    }

    await Future<void>.delayed(const Duration(milliseconds: 350));
    final nextId = _items.isEmpty
        ? 16
        : _items.map((e) => e.idKomplain).reduce((a, b) => a > b ? a : b) + 1;

    final baru = KomplainModel(
      idKomplain: nextId,
      idUser: idUser,
      idKamar: idKamar,
      judulKomplain: judulKomplain.trim(),
      deskripsiKomplain: deskripsiKomplain.trim(),
      fotoKomplain: namaFoto,
      statusKomplain: 'menunggu',
      tglKomplain: 'Baru saja • WIB',
      kodeKamar: kodeKamar,
      namaPenghuni: namaPenghuni,
      kategoriFasilitas: kategoriFasilitas,
      prioritas: 'Prioritas Tinggi',
    );
    _items.insert(0, baru);
    return baru;
  }

  /// Pemilik mengubah status tiket (menunggu -> sedang_diperbaiki -> selesai) & kirim FCM
  Future<KomplainModel> updateStatusKomplain({
    required int idKomplain,
    required String statusBaru,
    required String catatanTeknisi,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final index = _items.indexWhere((e) => e.idKomplain == idKomplain);
    if (index == -1) {
      throw const RepositoryException('Tiket komplain tidak ditemukan.');
    }

    final current = _items[index];
    final updated = current.copyWith(
      statusKomplain: statusBaru,
      catatanKomplain: catatanTeknisi.trim().isNotEmpty
          ? catatanTeknisi.trim()
          : current.catatanKomplain,
    );
    _items[index] = updated;

    final statusLabel = statusBaru == 'sedang_diperbaiki'
        ? 'Sedang Diperbaiki'
        : statusBaru == 'selesai'
        ? 'Selesai'
        : 'Menunggu';

    await _fcmService.sendPushNotification(
      title: 'Update Tiket ${current.kodeTiket}: $statusLabel',
      body: catatanTeknisi.trim().isNotEmpty
          ? catatanTeknisi.trim()
          : 'Status laporan "${current.judulKomplain}" diperbarui menjadi $statusLabel.',
      type: 'komplain',
      targetId: current.idKomplain,
    );

    return updated;
  }
}
