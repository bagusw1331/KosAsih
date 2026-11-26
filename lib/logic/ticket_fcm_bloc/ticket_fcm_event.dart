import 'dart:io';

import '../../data/services/fcm_service.dart';

sealed class TicketFcmEvent {
  const TicketFcmEvent();
}

final class TicketRequested extends TicketFcmEvent {
  const TicketRequested();
}

final class TicketCreated extends TicketFcmEvent {
  const TicketCreated({
    required this.idUser,
    required this.idKamar,
    required this.kodeKamar,
    required this.namaPenghuni,
    required this.kategoriFasilitas,
    required this.judulKomplain,
    required this.deskripsiKomplain,
    this.fotoKerusakan,
  });

  final int idUser;
  final int idKamar;
  final String kodeKamar;
  final String namaPenghuni;
  final String kategoriFasilitas;
  final String judulKomplain;
  final String deskripsiKomplain;
  final File? fotoKerusakan;
}

final class TicketUpdated extends TicketFcmEvent {
  const TicketUpdated({
    required this.idKomplain,
    required this.statusBaru,
    required this.catatanTeknisi,
  });

  final int idKomplain;
  final String statusBaru;
  final String catatanTeknisi;
}

final class AnnouncementBroadcasted extends TicketFcmEvent {
  const AnnouncementBroadcasted({
    required this.judul,
    required this.isi,
    required this.kategori,
    this.pin = false,
  });

  final String judul;
  final String isi;
  final String kategori;
  final bool pin;
}

final class AnnouncementUpdated extends TicketFcmEvent {
  const AnnouncementUpdated({
    required this.idPengumuman,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.pin,
  });

  final int idPengumuman;
  final String judul;
  final String isi;
  final String kategori;
  final bool pin;
}

final class AnnouncementDeleted extends TicketFcmEvent {
  const AnnouncementDeleted(this.idPengumuman);

  final int idPengumuman;
}

final class FcmMessageReceived extends TicketFcmEvent {
  const FcmMessageReceived(this.payload);

  final FcmNotificationPayload payload;
}