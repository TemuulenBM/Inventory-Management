import 'package:flutter/widgets.dart';

/// Tailwind-style spacing system
/// 4px base unit (xs=4, sm=8, md=16, lg=24, xl=32, xxl=48)
class AppSpacing {
  AppSpacing._();

  // Base spacing values (in logical pixels)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Additional granular spacing
  static const double space2 = 2.0;
  static const double space6 = 6.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space20 = 20.0;
  static const double space28 = 28.0;
  static const double space36 = 36.0;
  static const double space40 = 40.0;
  static const double space56 = 56.0;
  static const double space72 = 72.0;

  // EdgeInsets Presets - All sides equal
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);

  // EdgeInsets Presets - Horizontal
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(horizontal: xl);

  // EdgeInsets Presets - Vertical
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(vertical: xl);

  // Common Combinations
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: lg,
  );
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );

  // SizedBox Presets - Vertical spacing
  static const SizedBox verticalXS = SizedBox(height: xs);
  static const SizedBox verticalSM = SizedBox(height: sm);
  static const SizedBox verticalMD = SizedBox(height: md);
  static const SizedBox verticalLG = SizedBox(height: lg);
  static const SizedBox verticalXL = SizedBox(height: xl);
  static const SizedBox verticalXXL = SizedBox(height: xxl);

  // SizedBox Presets - Horizontal spacing
  static const SizedBox horizontalXS = SizedBox(width: xs);
  static const SizedBox horizontalSM = SizedBox(width: sm);
  static const SizedBox horizontalMD = SizedBox(width: md);
  static const SizedBox horizontalLG = SizedBox(width: lg);
  static const SizedBox horizontalXL = SizedBox(width: xl);
  static const SizedBox horizontalXXL = SizedBox(width: xxl);

  // Screen-specific spacing
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 80.0;
  static const double fabSize = 56.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;
}
