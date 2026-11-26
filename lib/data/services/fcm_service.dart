import 'dart:async';

class FcmNotificationPayload {
  const FcmNotificationPayload({
    required this.title,
    required this.body,
    required this.type,
    this.targetId,
    required this.receivedAt,
  });

  final String title;
  final String body;

  /// 'komplain' | 'pengumuman' | 'pembayaran'
  final String type;
  final int? targetId;
  final DateTime receivedAt;
}

class FcmService {
  FcmService._internal();
  static final FcmService instance = FcmService._internal();

  final StreamController<FcmNotificationPayload> _notificationController =
      StreamController<FcmNotificationPayload>.broadcast();

  String? _cachedToken;

  Stream<FcmNotificationPayload> get onMessageStream =>
      _notificationController.stream;

  /// Mengambil token FCM perangkat untuk disimpan ke tabel kostASIH_md_user.
  Future<String> getFcmToken() async {
    if (_cachedToken != null) return _cachedToken!;
    // TODO: Sambungkan ke FirebaseMessaging.instance.getToken() setelah package terpasang
    _cachedToken =
        'fcm_kostasih_device_${DateTime.now().millisecondsSinceEpoch}';
    return _cachedToken!;
  }

  /// Listener notifikasi foreground & background.
  void initializeListeners({
    void Function(FcmNotificationPayload payload)? onForegroundMessage,
  }) {
    if (onForegroundMessage != null) {
      onMessageStream.listen(onForegroundMessage);
    }
  }

  /// Memicu notifikasi push saat ada perubahan status komplain, pembayaran, atau siaran baru.
  Future<void> sendPushNotification({
    required String title,
    required String body,
    required String type,
    int? targetId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final payload = FcmNotificationPayload(
      title: title,
      body: body,
      type: type,
      targetId: targetId,
      receivedAt: DateTime.now(),
    );
    _notificationController.add(payload);
  }

  void dispose() {
    _notificationController.close();
  }
}
