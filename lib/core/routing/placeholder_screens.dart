import 'package:flutter/material.dart';

/// Placeholder screens (Sprint 7 Үе Шат 4-д бодит screens-ээр солигдоно)
///
/// ✅ ДУУССАН SCREENS:
/// - Splash, PhoneAuth, OtpScreen (Auth)
/// - Dashboard (Main)
/// - QuickSaleSelect, Cart (Sales)
/// - ProductsList, ProductDetail, ProductForm (Inventory)
///
/// ⏳ ҮЛДСЭН PLACEHOLDERS:
/// - Alerts, Shifts, Sync, Settings (Sprint 8-д хийгдэнэ)

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
