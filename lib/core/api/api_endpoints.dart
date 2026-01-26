/// API Endpoints
/// Backend API-ийн бүх endpoints
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String otpRequest = '/auth/otp/request';
  static const String otpVerify = '/auth/otp/verify';
  static const String deviceLogin = '/auth/device-login';
  static const String trustedDevices = '/auth/trusted-devices';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Stores
  static const String stores = '/stores';
  static String store(String storeId) => '/stores/$storeId';

  // Users
  static String users(String storeId) => '/stores/$storeId/users';
  static String user(String storeId, String userId) => '/stores/$storeId/users/$userId';

  // Products
  static String products(String storeId) => '/stores/$storeId/products';
  static String product(String storeId, String productId) => '/stores/$storeId/products/$productId';
  static String productsBulk(String storeId) => '/stores/$storeId/products/bulk';
  static String productImage(String storeId, String productId) =>
      '/stores/$storeId/products/$productId/image';

  // Inventory
  static String inventoryEvents(String storeId) => '/stores/$storeId/inventory-events';
  static String stockLevels(String storeId) => '/stores/$storeId/stock-levels';
  static String stockHistory(String storeId, String productId) =>
      '/stores/$storeId/products/$productId/stock-history';

  // Sales
  static String sales(String storeId) => '/stores/$storeId/sales';
  static String sale(String storeId, String saleId) => '/stores/$storeId/sales/$saleId';
  static String voidSale(String storeId, String saleId) => '/stores/$storeId/sales/$saleId/void';

  // Shifts
  static String shifts(String storeId) => '/stores/$storeId/shifts';
  static String shift(String storeId, String shiftId) => '/stores/$storeId/shifts/$shiftId';
  static String activeShift(String storeId) => '/stores/$storeId/shifts/active';
  static String openShift(String storeId) => '/stores/$storeId/shifts/open';
  static String closeShift(String storeId) => '/stores/$storeId/shifts/close';

  // Alerts
  static String alerts(String storeId) => '/stores/$storeId/alerts';
  static String alert(String storeId, String alertId) => '/stores/$storeId/alerts/$alertId';
  static String resolveAlert(String storeId, String alertId) =>
      '/stores/$storeId/alerts/$alertId/resolve';

  // Reports
  static String reports(String storeId) => '/stores/$storeId/reports';

  // Sync
  static String sync(String storeId) => '/stores/$storeId/sync';
  static String changes(String storeId) => '/stores/$storeId/changes';

  // Invitations (super-admin only)
  static const String invitations = '/invitations';
  static String invitation(String invitationId) => '/invitations/$invitationId';

  // Multi-Store Support
  /// Хэрэглэгчийн бүх дэлгүүрүүдийг авах (owner олон дэлгүүртэй байх)
  static String userStores(String userId) => '/users/$userId/stores';

  /// Дэлгүүр сонгох (primary store шинэчлэх)
  static String selectStore(String userId, String storeId) =>
      '/users/$userId/stores/$storeId/select';

  // Health
  static const String health = '/health';
}
