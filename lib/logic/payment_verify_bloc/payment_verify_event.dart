/// Event kerangka untuk PaymentVerifyBloc.
sealed class PaymentVerifyEvent {}

class PaymentVerificationRequested extends PaymentVerifyEvent {}

class PaymentApproved extends PaymentVerifyEvent {}

class PaymentRejected extends PaymentVerifyEvent {}
