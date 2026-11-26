/// State kerangka untuk BillingBloc.
sealed class BillingState {}

class BillingInitial extends BillingState {}

class BillingLoading extends BillingState {}

class BillingLoaded extends BillingState {}

class BillingFailure extends BillingState {}
