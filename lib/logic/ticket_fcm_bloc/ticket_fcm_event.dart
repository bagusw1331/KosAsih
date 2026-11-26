/// Event kerangka untuk TicketFcmBloc.
sealed class TicketFcmEvent {}

class TicketRequested extends TicketFcmEvent {}

class TicketCreated extends TicketFcmEvent {}

class TicketUpdated extends TicketFcmEvent {}

class FcmMessageReceived extends TicketFcmEvent {}
