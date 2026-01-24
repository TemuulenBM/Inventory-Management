/// API Endpoints
/// Backend API-ийн бүх endpoints
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String otpRequest = '/auth/otp/request';
  static const String otpVerify = '/auth/otp/verify';
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

  // Inventory
  static String inventory(String storeId) => '/stores/$storeId/inventory';
  static String stockLevels(String storeId) => '/stores/$storeId/inventory/stock-levels';

  // Sales
  static String sales(String storeId) => '/stores/$storeId/sales';
  static String sale(String storeId, String saleId) => '/stores/$storeId/sales/$saleId';

  // Shifts
  static String shifts(String storeId) => '/stores/$storeId/shifts';
  static String shift(String storeId, String shiftId) => '/stores/$storeId/shifts/$shiftId';

  // Alerts
  static String alerts(String storeId) => '/stores/$storeId/alerts';
  static String alert(String storeId, String alertId) => '/stores/$storeId/alerts/$alertId';

  // Reports
  static String reports(String storeId) => '/stores/$storeId/reports';

  // Sync
  static String sync(String storeId) => '/stores/$storeId/sync';

  // Health
  static const String health = '/health';
}
