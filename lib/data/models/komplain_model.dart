class KomplainModel {
  const KomplainModel({
    required this.idKomplain,
    required this.idUser,
    required this.idKamar,
    required this.judulKomplain,
    required this.deskripsiKomplain,
    this.fotoKomplain,
    this.catatanKomplain,
    required this.statusKomplain,
    required this.tglKomplain,
    // Field pendamping tampilan UI
    this.kodeKamar = '-',
    this.namaPenghuni = 'Penghuni',
    this.kategoriFasilitas = 'Fasilitas Umum',
    this.prioritas = 'Normal',
  });

  final int idKomplain;
  final int idUser;
  final int idKamar;
  final String judulKomplain;
  final String deskripsiKomplain;
  final String? fotoKomplain;
  final String? catatanKomplain;

  /// Nilai status: 'menunggu' | 'sedang_diperbaiki' | 'selesai'
  final String statusKomplain;
  final String tglKomplain;

  final String kodeKamar;
  final String namaPenghuni;
  final String kategoriFasilitas;
  final String prioritas;

  String get kodeTiket => '#TKT-${idKomplain.toString().padLeft(3, '0')}';

  factory KomplainModel.fromJson(Map<String, dynamic> json) {
    return KomplainModel(
      idKomplain: _toInt(json['id_komplain']),
      idUser: _toInt(json['id_user']),
      idKamar: _toInt(json['id_kamar']),
      judulKomplain: (json['judul_komplain'] ?? '').toString(),
      deskripsiKomplain: (json['deskripsi_komplain'] ?? '').toString(),
      fotoKomplain: json['foto_komplain']?.toString(),
      catatanKomplain: json['catatan_komplain']?.toString(),
      statusKomplain: (json['status_komplain'] ?? 'menunggu').toString(),
      tglKomplain: (json['tgl_komplain'] ?? '').toString(),
      kodeKamar: (json['nomor_kamar'] ?? json['kode_kamar'] ?? '-').toString(),
      namaPenghuni: (json['nama_user'] ?? json['nama_penghuni'] ?? 'Penghuni')
          .toString(),
      kategoriFasilitas: (json['kategori_fasilitas'] ?? 'Fasilitas Umum')
          .toString(),
      prioritas: (json['prioritas'] ?? 'Normal').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_komplain': idKomplain,
      'id_user': idUser,
      'id_kamar': idKamar,
      'judul_komplain': judulKomplain,
      'deskripsi_komplain': deskripsiKomplain,
      'foto_komplain': fotoKomplain,
      'catatan_komplain': catatanKomplain,
      'status_komplain': statusKomplain,
      'tgl_komplain': tglKomplain,
    };
  }

  KomplainModel copyWith({
    String? catatanKomplain,
    String? statusKomplain,
    String? tglKomplain,
  }) {
    return KomplainModel(
      idKomplain: idKomplain,
      idUser: idUser,
      idKamar: idKamar,
      judulKomplain: judulKomplain,
      deskripsiKomplain: deskripsiKomplain,
      fotoKomplain: fotoKomplain,
      catatanKomplain: catatanKomplain ?? this.catatanKomplain,
      statusKomplain: statusKomplain ?? this.statusKomplain,
      tglKomplain: tglKomplain ?? this.tglKomplain,
      kodeKamar: kodeKamar,
      namaPenghuni: namaPenghuni,
      kategoriFasilitas: kategoriFasilitas,
      prioritas: prioritas,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
