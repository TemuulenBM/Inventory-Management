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
/// - Sync (Sprint 8-д хийгдэнэ)
/// ✅ Settings → settings_screen.dart руу шилжсэн
/// ✅ Alerts → alerts_screen.dart руу шилжсэн
/// ✅ Shifts → shift_management_screen.dart руу шилжсэн

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
