import '../models/pengumuman_model.dart';
import '../services/fcm_service.dart';
import 'repository_exception.dart';

class PengumumanRepository {
  PengumumanRepository({FcmService? fcmService})
    : _fcmService = fcmService ?? FcmService.instance;

  final FcmService _fcmService;

  final List<PengumumanModel> _items = [
    const PengumumanModel(
      idPengumuman: 1,
      judulPengumuman: 'Jadwal Pengurasan Tandon Air Kos',
      isiPengumuman:
          'Jumat, 16 Okt 2026 pukul 09.00 - 11.30 WIB akan dilakukan pengurasan dan pembersihan tandon air utama. Aliran air dimatikan sementara. Mohon penghuni menampung air secukupnya.',
      pinPengumuman: true,
      tglPengumuman: 'Hari ini, 15 Okt 2026, 08:00 WIB',
      kategoriPengumuman: 'Air & Tandon',
      penulisPengumuman: 'Bu Asih',
    ),
    const PengumumanModel(
      idPengumuman: 2,
      judulPengumuman: 'Perubahan Password WiFi Oktober 2026',
      isiPengumuman:
          'Password WiFi KosAsih lantai 1 & 2 telah diperbarui menjadi: KosAsihOktober26 demi keamanan dan kelancaran akses bersama.',
      pinPengumuman: false,
      tglPengumuman: '01 Okt 2026, 07:30 WIB',
      kategoriPengumuman: 'Jaringan WiFi',
      penulisPengumuman: 'Bu Asih',
    ),
    const PengumumanModel(
      idPengumuman: 3,
      judulPengumuman: 'Himbauan Kunci Pagar Gerbang',
      isiPengumuman:
          'Dimohon seluruh penghuni memastikan pagar gerbang terkunci kembali setelah keluar/masuk di atas pukul 22.00 WIB.',
      pinPengumuman: false,
      tglPengumuman: '28 Sep 2026',
      kategoriPengumuman: 'Ketertiban Umum',
      penulisPengumuman: 'Bu Asih',
    ),
  ];

  Future<List<PengumumanModel>> fetchDaftarPengumuman() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final sorted = List<PengumumanModel>.from(_items)
      ..sort((a, b) {
        if (a.pinPengumuman == b.pinPengumuman) return 0;
        return a.pinPengumuman ? -1 : 1;
      });
    return sorted;
  }

  Future<PengumumanModel> kirimBroadcast({
    required String judul,
    required String isi,
    required String kategori,
    bool pin = false,
  }) async {
    if (judul.trim().isEmpty || isi.trim().isEmpty) {
      throw const RepositoryException('Judul dan isi pengumuman wajib diisi.');
    }

    await Future<void>.delayed(const Duration(milliseconds: 350));
    final nextId = _items.isEmpty
        ? 1
        : _items.map((e) => e.idPengumuman).reduce((a, b) => a > b ? a : b) + 1;

    final baru = PengumumanModel(
      idPengumuman: nextId,
      judulPengumuman: judul.trim(),
      isiPengumuman: isi.trim(),
      pinPengumuman: pin,
      tglPengumuman: 'Baru saja • WIB',
      kategoriPengumuman: kategori,
      penulisPengumuman: 'Bu Asih',
    );
    _items.insert(0, baru);

    await _fcmService.sendPushNotification(
      title: 'Pengumuman KosAsih: ${judul.trim()}',
      body: isi.trim(),
      type: 'pengumuman',
      targetId: baru.idPengumuman,
    );

    return baru;
  }

  Future<PengumumanModel> editPengumuman({
    required int idPengumuman,
    required String judul,
    required String isi,
    required String kategori,
    required bool pin,
  }) async {
    if (judul.trim().isEmpty || isi.trim().isEmpty) {
      throw const RepositoryException('Judul dan isi pengumuman wajib diisi.');
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));
    final index = _items.indexWhere((e) => e.idPengumuman == idPengumuman);
    if (index == -1) {
      throw const RepositoryException('Pengumuman tidak ditemukan.');
    }

    final updated = _items[index].copyWith(
      judulPengumuman: judul.trim(),
      isiPengumuman: isi.trim(),
      kategoriPengumuman: kategori,
      pinPengumuman: pin,
    );
    _items[index] = updated;
    return updated;
  }

  Future<void> hapusPengumuman(int idPengumuman) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _items.removeWhere((e) => e.idPengumuman == idPengumuman);
  }
}
