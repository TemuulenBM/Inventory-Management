import 'package:flutter/widgets.dart';

/// Border radius constants (дизайн файлуудаас: 0.5rem to 2rem)
/// 1rem ≈ 16px, тэгэхээр 0.5rem = 8px
class AppRadius {
  AppRadius._();

  // Base radius values (in logical pixels)
  static const double xs = 4.0; // 0.25rem
  static const double sm = 8.0; // 0.5rem
  static const double md = 12.0; // 0.75rem
  static const double lg = 16.0; // 1rem
  static const double xl = 24.0; // 1.5rem
  static const double xxl = 32.0; // 2rem

  // Special radius values
  static const double full = 9999.0; // Fully rounded (pill shape)
  static const double none = 0.0; // No radius

  // BorderRadius Presets
  static final BorderRadius radiusNone = BorderRadius.circular(none);
  static final BorderRadius radiusXS = BorderRadius.circular(xs);
  static final BorderRadius radiusSM = BorderRadius.circular(sm);
  static final BorderRadius radiusMD = BorderRadius.circular(md);
  static final BorderRadius radiusLG = BorderRadius.circular(lg);
  static final BorderRadius radiusXL = BorderRadius.circular(xl);
  static final BorderRadius radiusXXL = BorderRadius.circular(xxl);
  static final BorderRadius radiusFull = BorderRadius.circular(full);

  // Specific component radius
  static final BorderRadius buttonRadius = radiusLG; // 16px
  static final BorderRadius cardRadius = radiusLG; // 16px
  static final BorderRadius inputRadius = radiusMD; // 12px
  static final BorderRadius modalRadius = radiusXL; // 24px
  static final BorderRadius chipRadius = radiusFull; // Pill shape
  static final BorderRadius bottomSheetRadius = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );

  // Radius Presets - Individual corners
  static BorderRadius topLeftRadius(double value) => BorderRadius.only(
        topLeft: Radius.circular(value),
      );

  static BorderRadius topRightRadius(double value) => BorderRadius.only(
        topRight: Radius.circular(value),
      );

  static BorderRadius bottomLeftRadius(double value) => BorderRadius.only(
        bottomLeft: Radius.circular(value),
      );

  static BorderRadius bottomRightRadius(double value) => BorderRadius.only(
        bottomRight: Radius.circular(value),
      );

  // Radius Presets - Top/Bottom combinations
  static BorderRadius topRadius(double value) => BorderRadius.only(
        topLeft: Radius.circular(value),
        topRight: Radius.circular(value),
      );

  static BorderRadius bottomRadius(double value) => BorderRadius.only(
        bottomLeft: Radius.circular(value),
        bottomRight: Radius.circular(value),
      );

  // Radius Presets - Left/Right combinations
  static BorderRadius leftRadius(double value) => BorderRadius.only(
        topLeft: Radius.circular(value),
        bottomLeft: Radius.circular(value),
      );

  static BorderRadius rightRadius(double value) => BorderRadius.only(
        topRight: Radius.circular(value),
        bottomRight: Radius.circular(value),
      );
}
