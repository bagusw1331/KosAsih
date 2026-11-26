import '../../data/models/komplain_model.dart';
import '../../data/models/pengumuman_model.dart';
import '../../data/services/fcm_service.dart';

sealed class TicketFcmState {
  const TicketFcmState();
}

final class TicketFcmInitial extends TicketFcmState {
  const TicketFcmInitial();
}

final class TicketFcmLoading extends TicketFcmState {
  const TicketFcmLoading();
}

final class TicketFcmLoaded extends TicketFcmState {
  const TicketFcmLoaded({
    required this.daftarKomplain,
    required this.daftarPengumuman,
    this.fcmToken,
    this.latestNotification,
    this.actionMessage,
  });

  final List<KomplainModel> daftarKomplain;
  final List<PengumumanModel> daftarPengumuman;
  final String? fcmToken;
  final FcmNotificationPayload? latestNotification;
  final String? actionMessage;

  TicketFcmLoaded copyWith({
    List<KomplainModel>? daftarKomplain,
    List<PengumumanModel>? daftarPengumuman,
    String? fcmToken,
    FcmNotificationPayload? latestNotification,
    String? actionMessage,
  }) {
    return TicketFcmLoaded(
      daftarKomplain: daftarKomplain ?? this.daftarKomplain,
      daftarPengumuman: daftarPengumuman ?? this.daftarPengumuman,
      fcmToken: fcmToken ?? this.fcmToken,
      latestNotification: latestNotification ?? this.latestNotification,
      actionMessage: actionMessage,
    );
  }
}

final class TicketFcmFailure extends TicketFcmState {
  const TicketFcmFailure(this.message);

  final String message;
}