/// Nama route terpusat untuk navigasi aplikasi KosAsih.
abstract final class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';

  static const String ownerDashboard = '/owner/dashboard';
  static const String ownerRooms = '/owner/rooms';
  static const String ownerTenants = '/owner/tenants';
  static const String ownerBilling = '/owner/billing';
  static const String ownerPaymentVerification = '/owner/payment-verification';

  static const String tenantHome = '/tenant/home';
  static const String tenantPayment = '/tenant/payment';
  static const String tenantComplaint = '/tenant/complaint';
  static const String tenantAnnouncements = '/tenant/announcements';
  static const String tenantGuide = '/tenant/guide';
}
