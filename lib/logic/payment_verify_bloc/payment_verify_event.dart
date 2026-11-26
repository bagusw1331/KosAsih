import 'dart:io';

sealed class PaymentVerifyEvent {
  const PaymentVerifyEvent();
}

final class PaymentVerificationRequested extends PaymentVerifyEvent {
  const PaymentVerificationRequested();
}

final class PaymentProofSubmitted extends PaymentVerifyEvent {
  const PaymentProofSubmitted({
    required this.idPembayaran,
    required this.fileBukti,
    required this.metodePembayaran,
  });

  final int idPembayaran;
  final File fileBukti;
  final String metodePembayaran;
}

final class PaymentApproved extends PaymentVerifyEvent {
  const PaymentApproved(this.idPembayaran);

  final int idPembayaran;
}

final class PaymentRejected extends PaymentVerifyEvent {
  const PaymentRejected({
    required this.idPembayaran,
    required this.alasanPenolakan,
  });

  final int idPembayaran;
  final String alasanPenolakan;
}