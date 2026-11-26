/// Event kerangka untuk RoomTenantBloc.
sealed class RoomTenantEvent {}

class RoomTenantRequested extends RoomTenantEvent {}

class RoomTenantCreated extends RoomTenantEvent {}

class RoomTenantUpdated extends RoomTenantEvent {}

class RoomTenantDeleted extends RoomTenantEvent {}
