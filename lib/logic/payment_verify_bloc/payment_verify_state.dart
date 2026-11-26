import '../../data/models/pembayaran_model.dart';

sealed class PaymentVerifyState {
  const PaymentVerifyState();
}

final class PaymentVerifyInitial extends PaymentVerifyState {
  const PaymentVerifyInitial();
}

final class PaymentVerifyLoading extends PaymentVerifyState {
  const PaymentVerifyLoading();
}

final class PaymentVerifyLoaded extends PaymentVerifyState {
  const PaymentVerifyLoaded({
    required this.daftarPembayaran,
    this.actionMessage,
  });

  final List<PembayaranModel> daftarPembayaran;
  final String? actionMessage;
}

final class PaymentVerifyFailure extends PaymentVerifyState {
  const PaymentVerifyFailure(this.message);

  final String message;
}