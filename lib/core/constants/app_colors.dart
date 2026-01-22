import 'dart:ui';

/// Дизайн системийн өнгөний constants
/// Дизайн файлуудаас авсан (#c2755b primary, #00878F success, гэх мэт)
class AppColors {
  AppColors._();

  // Primary Colors (Terracotta/Rust theme)
  static const Color primary = Color(0xFFC2755B);
  static const Color primaryHover = Color(0xFFA8644D);
  static const Color primaryDark = Color(0xFFA05A43);
  static const Color primaryLight = Color(0xFFD4896F);

  // Secondary/Action Colors (Teal)
  static const Color secondary = Color(0xFF00878F);
  static const Color secondaryDark = Color(0xFF006B72);
  static const Color secondaryLight = Color(0xFF3D7A6E);

  // Semantic Colors
  static const Color success = Color(0xFF00878F); // Teal - ижил secondary
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE0A63B);
  static const Color warningOrange = Color(0xFFF57C00);
  static const Color danger = Color(0xFFAF4D4D);
  static const Color dangerRed = Color(0xFFD32F2F);
  static const Color error = Color(0xFFe74c3c);
  static const Color suspicious = Color(0xFFF57C00); // Orange

  // Status Colors (Inventory)
  static const Color statusNormal = Color(0xFF3D7A6E); // Emerald
  static const Color statusLowStock = Color(0xFFF57C00); // Orange
  static const Color statusOutOfStock = Color(0xFFD32F2F); // Red
  static const Color statusActive = Color(0xFF00878F); // Teal

  // Background Colors - Light Mode
  static const Color backgroundLight = Color(0xFFFBFAF9); // Off-white/warm beige
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF5F4F3);

  // Background Colors - Dark Mode
  static const Color backgroundDark = Color(0xFF1D2025); // Very dark gray
  static const Color surfaceDark = Color(0xFF2A2D33);
  static const Color surfaceVariantDark = Color(0xFF25282E);

  // Text Colors - Light Mode
  static const Color textMainLight = Color(0xFF181311); // Very dark brown
  static const Color textSecondaryLight = Color(0xFF87685E); // Muted brown
  static const Color textTertiaryLight = Color(0xFFA0908A);

  // Text Colors - Dark Mode
  static const Color textMainDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFF0ECEA);
  static const Color textTertiaryDark = Color(0xFFA1A1AA);

  // Glass/Translucent Effects
  static const Color glassWhite = Color(0xB3FFFFFF); // rgba(255,255,255,0.7)
  static const Color glassDark = Color(0x4D000000); // rgba(0,0,0,0.3)
  static const Color glassBorder = Color(0x80FFFFFF); // rgba(255,255,255,0.5)

  // Shadows & Overlays
  static const Color shadowLight = Color(0x1AC2755B); // rgba(194,117,91,0.1)
  static const Color shadowMedium = Color(0x40C2755B); // rgba(194,117,91,0.25)
  static const Color overlayDark = Color(0x80000000); // rgba(0,0,0,0.5)

  // Alert Backgrounds (Light mode)
  static const Color warningBackground = Color(0xFFFFF4E5);
  static const Color errorBackground = Color(0xFFFFEBEE);
  static const Color successBackground = Color(0xFFE8F5E9);
  static const Color infoBackground = Color(0xFFE3F2FD);

  // Neutral Grays
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Special Colors
  static const Color transparent = Color(0x00000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
