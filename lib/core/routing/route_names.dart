/// Route constants for navigation
class RouteNames {
  RouteNames._();

  // Onboarding & Auth
  static const String splash = '/splash';
  static const String authPhone = '/auth/phone';
  static const String authOtp = '/auth/otp';

  // Main App
  static const String dashboard = '/dashboard';

  // Sales
  static const String quickSaleSelect = '/sales';
  static const String quickSaleCart = '/sales/cart';

  // Inventory
  static const String inventory = '/inventory';
  static const String productDetail = '/product/:id';
  static const String addProduct = '/inventory/add';
  static const String editProduct = '/inventory/edit/:id';

  // Shifts
  static const String shifts = '/shifts';
  static const String shiftDetail = '/shifts/:id';

  // Alerts
  static const String alerts = '/alerts';

  // Sync
  static const String syncConflicts = '/sync';

  // Settings
  static const String settings = '/settings';
  static const String profile = '/settings/profile';

  // Helper method to build product detail route
  static String productDetailPath(String productId) {
    return '/product/$productId';
  }

  // Helper method to build shift detail route
  static String shiftDetailPath(String shiftId) {
    return '/shifts/$shiftId';
  }

  // Helper method to build edit product route
  static String editProductPath(String productId) {
    return '/inventory/edit/$productId';
  }
}
