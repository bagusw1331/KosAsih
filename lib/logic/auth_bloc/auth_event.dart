/// Event kerangka untuk AuthBloc.
sealed class AuthEvent {}

class AuthStarted extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {}

class AuthRegisterRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}
