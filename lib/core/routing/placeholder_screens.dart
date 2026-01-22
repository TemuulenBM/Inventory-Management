import 'package:flutter/material.dart';

/// Placeholder screens (Sprint 7 Үе Шат 4-д бодит screens-ээр солигдоно)

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80),
            SizedBox(height: 24),
            Text(
              'Retail Control Platform',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class PhoneAuthScreen extends StatelessWidget {
  const PhoneAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Auth')),
      body: const Center(child: Text('Phone Auth Screen (Placeholder)')),
    );
  }
}

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification')),
      body: const Center(child: Text('OTP Screen (Placeholder)')),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(child: Text('Dashboard Screen (Placeholder)')),
    );
  }
}

class QuickSaleSelectScreen extends StatelessWidget {
  const QuickSaleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Sale')),
      body: const Center(child: Text('Quick Sale Select Screen (Placeholder)')),
    );
  }
}

class QuickSaleCartScreen extends StatelessWidget {
  const QuickSaleCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: const Center(child: Text('Cart Screen (Placeholder)')),
    );
  }
}

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: const Center(child: Text('Inventory Screen (Placeholder)')),
    );
  }
}

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: Center(child: Text('Product Detail: $productId (Placeholder)')),
    );
  }
}

class AlertsCenterScreen extends StatelessWidget {
  const AlertsCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: const Center(child: Text('Alerts Screen (Placeholder)')),
    );
  }
}

class ShiftManagementScreen extends StatelessWidget {
  const ShiftManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shifts')),
      body: const Center(child: Text('Shift Management Screen (Placeholder)')),
    );
  }
}

class SyncConflictsScreen extends StatelessWidget {
  const SyncConflictsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sync')),
      body: const Center(child: Text('Sync & Conflicts Screen (Placeholder)')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Screen (Placeholder)')),
    );
  }
}
