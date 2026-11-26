/// State kerangka untuk PaymentVerifyBloc.
sealed class PaymentVerifyState {}

class PaymentVerifyInitial extends PaymentVerifyState {}

class PaymentVerifyLoading extends PaymentVerifyState {}

class PaymentVerifyLoaded extends PaymentVerifyState {}

class PaymentVerifyFailure extends PaymentVerifyState {}
