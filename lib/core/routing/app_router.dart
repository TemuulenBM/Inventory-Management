import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/routing/placeholder_screens.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';
import 'package:retail_control_platform/core/widgets/layout/main_shell.dart';
import 'package:retail_control_platform/features/auth/presentation/providers/auth_provider.dart';
import 'package:retail_control_platform/features/auth/presentation/screens/phone_auth_screen.dart';
import 'package:retail_control_platform/features/auth/presentation/screens/otp_screen.dart';
import 'package:retail_control_platform/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:retail_control_platform/features/onboarding/presentation/screens/onboarding_welcome_screen.dart';
import 'package:retail_control_platform/features/onboarding/presentation/screens/onboarding_store_setup_screen.dart';
import 'package:retail_control_platform/features/onboarding/presentation/screens/onboarding_products_screen.dart';
import 'package:retail_control_platform/features/onboarding/presentation/screens/onboarding_invite_screen.dart';
import 'package:retail_control_platform/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:retail_control_platform/features/sales/presentation/screens/quick_sale_select_screen.dart';
import 'package:retail_control_platform/features/sales/presentation/screens/cart_screen.dart';
import 'package:retail_control_platform/features/inventory/presentation/screens/products_list_screen.dart';
import 'package:retail_control_platform/features/inventory/presentation/screens/product_detail_screen.dart';
import 'package:retail_control_platform/features/inventory/presentation/screens/product_form_screen.dart';
import 'package:retail_control_platform/features/inventory/presentation/screens/inventory_events_screen.dart';
import 'package:retail_control_platform/features/settings/presentation/screens/settings_screen.dart';
import 'package:retail_control_platform/features/alerts/presentation/screens/alerts_screen.dart';
import 'package:retail_control_platform/features/shifts/presentation/screens/shift_management_screen.dart';
import 'package:retail_control_platform/features/invitation/presentation/screens/invitation_list_screen.dart';
import 'package:retail_control_platform/features/invitation/presentation/screens/invitation_form_screen.dart';
import 'package:retail_control_platform/features/settings/presentation/screens/profile_edit_screen.dart';
import 'package:retail_control_platform/features/settings/presentation/screens/store_edit_screen.dart';
import 'package:retail_control_platform/features/store/presentation/screens/store_selection_screen.dart';
import 'package:retail_control_platform/features/employees/presentation/screens/employee_list_screen.dart';
import 'package:retail_control_platform/features/employees/presentation/screens/employee_form_screen.dart';

/// GoRouter configuration for app navigation
/// Auth guards, deep linking, route transitions
/// RBAC: Super-admin role restrictions implemented

/// Global reference ашиглаж auth state-г route guard-д шалгах
/// Note: Энэ нь anti-pattern, гэхдээ GoRouter-ын redirect function нь
/// Riverpod ref-д хандах боломжгүй тул түр шийдэл болгон ашиглана
final _routerAuthContainer = ProviderContainer();

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  debugLogDiagnostics: true,
  redirect: _authGuard,
  routes: [
    // ===== SPLASH & AUTH =====
    GoRoute(
      path: RouteNames.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.authPhone,
      name: 'auth-phone',
      builder: (context, state) => const PhoneAuthScreen(),
    ),
    GoRoute(
      path: RouteNames.authOtp,
      name: 'auth-otp',
      builder: (context, state) {
        // extra нь Map эсвэл String байж болно (backward compatibility)
        String phoneNumber = '';
        bool trustDevice = false;

        if (state.extra is Map<String, dynamic>) {
          final data = state.extra as Map<String, dynamic>;
          phoneNumber = data['phone'] as String? ?? '';
          trustDevice = data['trustDevice'] as bool? ?? false;
        } else if (state.extra is String) {
          phoneNumber = state.extra as String;
        }

        return OtpScreen(phoneNumber: phoneNumber, trustDevice: trustDevice);
      },
    ),

    // ===== ONBOARDING (шинэ хэрэглэгч, bottom nav-гүй) =====
    GoRoute(
      path: RouteNames.onboardingWelcome,
      name: 'onboarding-welcome',
      builder: (context, state) => const OnboardingWelcomeScreen(),
    ),
    GoRoute(
      path: RouteNames.onboardingStoreSetup,
      name: 'onboarding-store-setup',
      builder: (context, state) => const OnboardingStoreSetupScreen(),
    ),
    GoRoute(
      path: RouteNames.onboardingProducts,
      name: 'onboarding-products',
      builder: (context, state) {
        final storeId = state.extra as String? ?? '';
        return OnboardingProductsScreen(storeId: storeId);
      },
    ),
    GoRoute(
      path: RouteNames.onboardingInvite,
      name: 'onboarding-invite',
      builder: (context, state) {
        final storeId = state.extra as String? ?? '';
        return OnboardingInviteScreen(storeId: storeId);
      },
    ),

    // ===== INVITATIONS (super-admin only, гадна bottom nav) =====
    GoRoute(
      path: RouteNames.invitations,
      name: 'invitations',
      builder: (context, state) => const InvitationListScreen(),
    ),
    GoRoute(
      path: RouteNames.createInvitation,
      name: 'create-invitation',
      builder: (context, state) => const InvitationFormScreen(),
    ),

    // ===== MAIN APP with Bottom Navigation =====
    ShellRoute(
      builder: (context, state, child) {
        // currentIndex тооцоолох (route-аас хамаарч)
        // Шинэ дараалал: 0=Нүүр, 1=Бараа, 2=Түүх, 3=Тохиргоо
        final location = state.uri.path;
        int index = 0;
        if (location.startsWith('/inventory') ||
            location.startsWith('/product')) {
          index = 1;
        } else if (location.startsWith('/history')) {
          index = 2;
        } else if (location.startsWith('/settings')) {
          index = 3;
        }

        return MainShell(currentIndex: index, child: child);
      },
      routes: [
        // Dashboard
        GoRoute(
          path: RouteNames.dashboard,
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        // Quick Sale
        GoRoute(
          path: RouteNames.quickSaleSelect,
          name: 'quick-sale-select',
          builder: (context, state) => const QuickSaleSelectScreen(),
        ),
        // Cart (sub-route of sales)
        GoRoute(
          path: RouteNames.quickSaleCart,
          name: 'quick-sale-cart',
          builder: (context, state) => const CartScreen(),
        ),
        // Inventory
        GoRoute(
          path: RouteNames.inventory,
          name: 'inventory',
          builder: (context, state) => const ProductsListScreen(),
        ),
        // Product Detail
        GoRoute(
          path: RouteNames.productDetail,
          name: 'product-detail',
          builder: (context, state) {
            final productId = state.pathParameters['id'] ?? '';
            return ProductDetailScreen(productId: productId);
          },
        ),
        // Inventory Events (Product History)
        GoRoute(
          path: RouteNames.inventoryEvents,
          name: 'inventory-events',
          builder: (context, state) {
            final productId = state.pathParameters['id'] ?? '';
            return InventoryEventsScreen(productId: productId);
          },
        ),
        // History (Global Inventory Events - bottom nav tab)
        GoRoute(
          path: RouteNames.history,
          name: 'history',
          builder: (context, state) => const InventoryEventsScreen(),
        ),
        // Add Product
        GoRoute(
          path: RouteNames.addProduct,
          name: 'add-product',
          builder: (context, state) =>
              const ProductFormScreen(productId: 'new'),
        ),
        // Edit Product
        GoRoute(
          path: RouteNames.editProduct,
          name: 'edit-product',
          builder: (context, state) {
            final productId = state.pathParameters['id'] ?? '';
            return ProductFormScreen(productId: productId);
          },
        ),
        // Settings
        GoRoute(
          path: RouteNames.settings,
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        // Profile Edit
        GoRoute(
          path: RouteNames.profileEdit,
          name: 'profile-edit',
          builder: (context, state) => const ProfileEditScreen(),
        ),
        // Store Edit
        GoRoute(
          path: RouteNames.storeEdit,
          name: 'store-edit',
          builder: (context, state) => const StoreEditScreen(),
        ),
        // Store Selection (Multi-store support)
        GoRoute(
          path: RouteNames.storeSelection,
          name: 'store-selection',
          builder: (context, state) => const StoreSelectionScreen(),
        ),
        // Employees List
        GoRoute(
          path: RouteNames.employees,
          name: 'employees',
          builder: (context, state) => const EmployeeListScreen(),
        ),
        // Employee Add
        GoRoute(
          path: RouteNames.employeeAdd,
          name: 'employee-add',
          builder: (context, state) => const EmployeeFormScreen(),
        ),
        // Employee Edit
        GoRoute(
          path: '/settings/employees/:id/edit',
          name: 'employee-edit',
          builder: (context, state) {
            final employeeId = state.pathParameters['id'] ?? '';
            return EmployeeFormScreen(employeeId: employeeId);
          },
        ),
        // Alerts
        GoRoute(
          path: RouteNames.alerts,
          name: 'alerts',
          builder: (context, state) => const AlertsScreen(),
        ),
        // Shifts
        GoRoute(
          path: RouteNames.shifts,
          name: 'shifts',
          builder: (context, state) => const ShiftManagementScreen(),
        ),
        // Sync
        GoRoute(
          path: RouteNames.syncConflicts,
          name: 'sync-conflicts',
          builder: (context, state) => const SyncConflictsScreen(),
        ),
      ],
    ),
  ],

  // Error handling
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Route not found: ${state.uri}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(RouteNames.dashboard),
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    ),
  ),
);

/// Auth guard redirect logic
/// Super-admin хязгаарлалт: дэлгүүрийн функцүүдэд хандахыг блоклоно
String? _authGuard(BuildContext context, GoRouterState state) {
  final location = state.uri.path;

  // Public routes (бүгдэд нээлттэй)
  if (location == RouteNames.splash ||
      location.startsWith('/auth') ||
      location.startsWith('/onboarding')) {
    return null;
  }

  // Хэрэглэгчийн мэдээлэл авах
  final user = _routerAuthContainer.read(currentUserProvider);

  // Super-admin эсэхийг шалгах
  final isSuperAdmin = user?.role == 'super_admin';

  if (isSuperAdmin) {
    // Super-admin-д хориглогдсон route-ууд
    final restrictedRoutes = [
      '/inventory',
      '/product',
      '/history',
      '/cart',
      '/quick-sale',
      '/shifts',
      '/alerts',
      '/employees',
      '/store-edit',
      '/store-selection',
      '/profile-edit',
    ];

    // Хэрэв хориглогдсон route руу орохыг оролдвол → redirect to dashboard
    for (final restrictedRoute in restrictedRoutes) {
      if (location.startsWith(restrictedRoute)) {
        // SnackBar харуулах боломжгүй (redirect function дотор)
        // Энэ нь зөвхөн redirect хийнэ, мессеж нь dashboard screen дээр харуулагдана
        return RouteNames.dashboard;
      }
    }

    // Зөвшөөрөгдсөн routes: /dashboard, /settings, /invitations, /create-invitation
    return null;
  }

  // Owner/Manager/Seller-д бүх routes нээлттэй
  return null;
}
