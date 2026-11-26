/// State kerangka untuk TicketFcmBloc.
sealed class TicketFcmState {}

class TicketFcmInitial extends TicketFcmState {}

class TicketFcmLoading extends TicketFcmState {}

class TicketFcmLoaded extends TicketFcmState {}

class TicketFcmFailure extends TicketFcmState {}
