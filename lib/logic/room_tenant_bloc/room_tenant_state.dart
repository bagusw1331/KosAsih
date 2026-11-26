/// State kerangka untuk RoomTenantBloc.
sealed class RoomTenantState {}

class RoomTenantInitial extends RoomTenantState {}

class RoomTenantLoading extends RoomTenantState {}

class RoomTenantLoaded extends RoomTenantState {}

class RoomTenantFailure extends RoomTenantState {}
