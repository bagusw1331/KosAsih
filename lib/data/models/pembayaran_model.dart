class PembayaranModel {
  const PembayaranModel({
    required this.idPembayaran,
    required this.idKamar,
    required this.idUser,
    required this.periodePembayaran,
    required this.tenggatPembayaran,
    required this.nominalPembayaran,
    required this.biayaTamuPembayaran,
    required this.dendaPembayaran,
    this.buktiPembayaran,
    this.kuitansiPembayaran,
    required this.statusPembayaran,
    this.tglLunasPembayaran,
    // Field pendamping tampilan UI
    this.kodeKamar = '-',
    this.namaPenghuni = 'Penghuni',
    this.infoKamar = '',
    this.metodePembayaran = 'Transfer Bank BCA',
    this.hariTerlambat = 0,
    this.alasanPenolakan,
  });

  final int idPembayaran;
  final int idKamar;
  final int idUser;
  final String periodePembayaran;
  final String tenggatPembayaran;
  final int nominalPembayaran;
  final int biayaTamuPembayaran;
  final int dendaPembayaran;
  final String? buktiPembayaran;
  final String? kuitansiPembayaran;

  /// Nilai status: 'belum_bayar' | 'menunggu_verifikasi' | 'terlambat' | 'lunas'
  final String statusPembayaran;
  final String? tglLunasPembayaran;

  final String kodeKamar;
  final String namaPenghuni;
  final String infoKamar;
  final String metodePembayaran;
  final int hariTerlambat;
  final String? alasanPenolakan;

  int get totalTagihan =>
      nominalPembayaran + biayaTamuPembayaran + dendaPembayaran;

  factory PembayaranModel.fromJson(Map<String, dynamic> json) {
    return PembayaranModel(
      idPembayaran: _toInt(json['id_pembayaran']),
      idKamar: _toInt(json['id_kamar']),
      idUser: _toInt(json['id_user']),
      periodePembayaran: (json['periode_pembayaran'] ?? '').toString(),
      tenggatPembayaran: (json['tenggat_pembayaran'] ?? '').toString(),
      nominalPembayaran: _toInt(json['nominal_pembayaran']),
      biayaTamuPembayaran: _toInt(json['biaya_tamu_pembayaran']),
      dendaPembayaran: _toInt(json['denda_pembayaran']),
      buktiPembayaran: json['bukti_pembayaran']?.toString(),
      kuitansiPembayaran: json['kuitansi_pembayaran']?.toString(),
      statusPembayaran: (json['status_pembayaran'] ?? 'belum_bayar').toString(),
      tglLunasPembayaran: json['tgl_lunas_pembayaran']?.toString(),
      kodeKamar: (json['nomor_kamar'] ?? json['kode_kamar'] ?? '-').toString(),
      namaPenghuni: (json['nama_user'] ?? json['nama_penghuni'] ?? 'Penghuni')
          .toString(),
      infoKamar: (json['tipe_kamar'] ?? json['info_kamar'] ?? '').toString(),
      metodePembayaran: (json['metode_pembayaran'] ?? 'Transfer Bank BCA')
          .toString(),
      hariTerlambat: _toInt(json['hari_terlambat']),
      alasanPenolakan: json['alasan_penolakan']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pembayaran': idPembayaran,
      'id_kamar': idKamar,
      'id_user': idUser,
      'periode_pembayaran': periodePembayaran,
      'tenggat_pembayaran': tenggatPembayaran,
      'nominal_pembayaran': nominalPembayaran,
      'biaya_tamu_pembayaran': biayaTamuPembayaran,
      'denda_pembayaran': dendaPembayaran,
      'bukti_pembayaran': buktiPembayaran,
      'kuitansi_pembayaran': kuitansiPembayaran,
      'status_pembayaran': statusPembayaran,
      'tgl_lunas_pembayaran': tglLunasPembayaran,
    };
  }

  PembayaranModel copyWith({
    String? buktiPembayaran,
    String? kuitansiPembayaran,
    String? statusPembayaran,
    String? tglLunasPembayaran,
    String? metodePembayaran,
    String? alasanPenolakan,
  }) {
    return PembayaranModel(
      idPembayaran: idPembayaran,
      idKamar: idKamar,
      idUser: idUser,
      periodePembayaran: periodePembayaran,
      tenggatPembayaran: tenggatPembayaran,
      nominalPembayaran: nominalPembayaran,
      biayaTamuPembayaran: biayaTamuPembayaran,
      dendaPembayaran: dendaPembayaran,
      buktiPembayaran: buktiPembayaran ?? this.buktiPembayaran,
      kuitansiPembayaran: kuitansiPembayaran ?? this.kuitansiPembayaran,
      statusPembayaran: statusPembayaran ?? this.statusPembayaran,
      tglLunasPembayaran: tglLunasPembayaran ?? this.tglLunasPembayaran,
      kodeKamar: kodeKamar,
      namaPenghuni: namaPenghuni,
      infoKamar: infoKamar,
      metodePembayaran: metodePembayaran ?? this.metodePembayaran,
      hariTerlambat: hariTerlambat,
      alasanPenolakan: alasanPenolakan ?? this.alasanPenolakan,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
