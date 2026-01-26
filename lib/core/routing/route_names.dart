/// Route constants for navigation
class RouteNames {
  RouteNames._();

  // Onboarding & Auth
  static const String splash = '/splash';
  static const String authPhone = '/auth/phone';
  static const String authOtp = '/auth/otp';

  // Onboarding (шинэ хэрэглэгч)
  static const String onboardingWelcome = '/onboarding/welcome';
  static const String onboardingStoreSetup = '/onboarding/store-setup';
  static const String onboardingProducts = '/onboarding/products';
  static const String onboardingInvite = '/onboarding/invite';

  // Main App
  static const String dashboard = '/dashboard';

  // Sales
  static const String quickSaleSelect = '/sales';
  static const String quickSaleCart = '/sales/cart';

  // Inventory
  static const String inventory = '/inventory';
  static const String productDetail = '/product/:id';
  static const String inventoryEvents = '/product/:id/events';
  static const String addProduct = '/inventory/add';
  static const String editProduct = '/inventory/edit/:id';

  // History (global inventory events)
  static const String history = '/history';

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
  static const String profileEdit = '/settings/profile/edit';

  // Store
  static const String storeEdit = '/settings/store/edit';

  // Employees
  static const String employees = '/settings/employees';
  static const String employeeAdd = '/settings/employees/add';

  // Invitations (super-admin only)
  static const String invitations = '/invitations';
  static const String createInvitation = '/invitations/create';

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

  // Helper method to build inventory events route
  static String inventoryEventsPath(String productId) {
    return '/product/$productId/events';
  }

  // Helper method to build employee edit route
  static String employeeEditPath(String employeeId) {
    return '/settings/employees/$employeeId/edit';
  }
}
