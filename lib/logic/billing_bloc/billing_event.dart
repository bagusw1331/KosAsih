/// Event kerangka untuk BillingBloc.
sealed class BillingEvent {}

class BillingRequested extends BillingEvent {}

class BillingCalculated extends BillingEvent {}

class BillingReceiptRequested extends BillingEvent {}
