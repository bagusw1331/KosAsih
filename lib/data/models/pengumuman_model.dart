class PengumumanModel {
  const PengumumanModel({
    required this.idPengumuman,
    required this.judulPengumuman,
    required this.isiPengumuman,
    required this.pinPengumuman,
    required this.tglPengumuman,
    // Field pendamping tampilan UI
    this.kategoriPengumuman = 'Informasi Umum',
    this.penulisPengumuman = 'Bu Asih',
  });

  final int idPengumuman;
  final String judulPengumuman;
  final String isiPengumuman;
  final bool pinPengumuman;
  final String tglPengumuman;

  final String kategoriPengumuman;
  final String penulisPengumuman;

  factory PengumumanModel.fromJson(Map<String, dynamic> json) {
    final rawPin = json['pin_pengumuman'];
    final bool isPinned = rawPin is bool
        ? rawPin
        : (rawPin == 1 || rawPin?.toString() == 'true');

    return PengumumanModel(
      idPengumuman: _toInt(json['id_pengumuman']),
      judulPengumuman: (json['judul_pengumuman'] ?? '').toString(),
      isiPengumuman: (json['isi_pengumuman'] ?? '').toString(),
      pinPengumuman: isPinned,
      tglPengumuman: (json['tgl_pengumuman'] ?? '').toString(),
      kategoriPengumuman: (json['kategori_pengumuman'] ?? 'Informasi Umum')
          .toString(),
      penulisPengumuman: (json['penulis_pengumuman'] ?? 'Bu Asih').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pengumuman': idPengumuman,
      'judul_pengumuman': judulPengumuman,
      'isi_pengumuman': isiPengumuman,
      'pin_pengumuman': pinPengumuman,
      'tgl_pengumuman': tglPengumuman,
    };
  }

  PengumumanModel copyWith({
    String? judulPengumuman,
    String? isiPengumuman,
    bool? pinPengumuman,
    String? tglPengumuman,
    String? kategoriPengumuman,
  }) {
    return PengumumanModel(
      idPengumuman: idPengumuman,
      judulPengumuman: judulPengumuman ?? this.judulPengumuman,
      isiPengumuman: isiPengumuman ?? this.isiPengumuman,
      pinPengumuman: pinPengumuman ?? this.pinPengumuman,
      tglPengumuman: tglPengumuman ?? this.tglPengumuman,
      kategoriPengumuman: kategoriPengumuman ?? this.kategoriPengumuman,
      penulisPengumuman: penulisPengumuman,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
