import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:retail_control_platform/core/routing/placeholder_screens.dart';
import 'package:retail_control_platform/core/routing/route_names.dart';
import 'package:retail_control_platform/features/auth/presentation/screens/phone_auth_screen.dart';
import 'package:retail_control_platform/features/auth/presentation/screens/otp_screen.dart';
import 'package:retail_control_platform/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:retail_control_platform/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:retail_control_platform/features/sales/presentation/screens/quick_sale_select_screen.dart';
import 'package:retail_control_platform/features/sales/presentation/screens/cart_screen.dart';
import 'package:retail_control_platform/features/inventory/presentation/screens/products_list_screen.dart';
import 'package:retail_control_platform/features/inventory/presentation/screens/product_detail_screen.dart';
import 'package:retail_control_platform/features/inventory/presentation/screens/product_form_screen.dart';

/// GoRouter configuration for app navigation
/// Auth guards, deep linking, route transitions

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

    // ===== MAIN APP =====
    GoRoute(
      path: RouteNames.dashboard,
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),

    // ===== SALES =====
    GoRoute(
      path: RouteNames.quickSaleSelect,
      name: 'quick-sale-select',
      builder: (context, state) => const QuickSaleSelectScreen(),
    ),
    GoRoute(
      path: RouteNames.quickSaleCart,
      name: 'quick-sale-cart',
      builder: (context, state) => const CartScreen(),
    ),

    // ===== INVENTORY =====
    GoRoute(
      path: RouteNames.inventory,
      name: 'inventory',
      builder: (context, state) => const ProductsListScreen(),
    ),
    GoRoute(
      path: RouteNames.addProduct,
      name: 'add-product',
      builder: (context, state) => const ProductFormScreen(productId: 'new'),
    ),
    GoRoute(
      path: RouteNames.editProduct,
      name: 'edit-product',
      builder: (context, state) {
        final productId = state.pathParameters['id'] ?? '';
        return ProductFormScreen(productId: productId);
      },
    ),
    GoRoute(
      path: RouteNames.productDetail,
      name: 'product-detail',
      builder: (context, state) {
        final productId = state.pathParameters['id'] ?? '';
        return ProductDetailScreen(productId: productId);
      },
    ),

    // ===== ALERTS =====
    GoRoute(
      path: RouteNames.alerts,
      name: 'alerts',
      builder: (context, state) => const AlertsCenterScreen(),
    ),

    // ===== SHIFTS =====
    GoRoute(
      path: RouteNames.shifts,
      name: 'shifts',
      builder: (context, state) => const ShiftManagementScreen(),
    ),

    // ===== SYNC =====
    GoRoute(
      path: RouteNames.syncConflicts,
      name: 'sync-conflicts',
      builder: (context, state) => const SyncConflictsScreen(),
    ),

    // ===== SETTINGS =====
    GoRoute(
      path: RouteNames.settings,
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
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
/// TODO: Үе Шат 3-д auth provider-тэй холбох
String? _authGuard(BuildContext context, GoRouterState state) {
  // For now, allow all routes (will implement proper auth check in Phase 3)
  // Splash screen always allowed
  if (state.uri.toString() == RouteNames.splash) {
    return null;
  }

  // Auth routes always allowed
  if (state.uri.toString().startsWith('/auth')) {
    return null;
  }

  // TODO: Check if user is authenticated
  // final isAuthenticated = // check auth provider
  // if (!isAuthenticated) {
  //   return RouteNames.authPhone;
  // }

  return null; // Allow navigation for now
}
