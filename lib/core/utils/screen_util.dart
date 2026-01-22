import 'package:flutter/widgets.dart';

/// Custom ScreenUtil for responsive design
/// Breakpoints: small (<360), medium (360-600), large (>=600)
class ScreenUtil {
  ScreenUtil._();

  // Breakpoint constants
  static const double smallScreenMaxWidth = 360.0;
  static const double tabletMinWidth = 600.0;
  static const double desktopMinWidth = 1024.0;

  /// Check if screen is small (<360px width)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < smallScreenMaxWidth;
  }

  /// Check if screen is medium (360-600px)
  static bool isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= smallScreenMaxWidth && width < tabletMinWidth;
  }

  /// Check if screen is tablet (>=600px)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletMinWidth && width < desktopMinWidth;
  }

  /// Check if screen is desktop (>=1024px)
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopMinWidth;
  }

  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get screen size
  static Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Get safe area padding (for notch, status bar, etc.)
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get device pixel ratio
  static double pixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// Responsive value based on screen size
  /// Usage: ScreenUtil.responsiveValue(context, small: 12, medium: 14, large: 16)
  static T responsiveValue<T>(
    BuildContext context, {
    required T small,
    T? medium,
    T? large,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && large != null) {
      return large;
    } else if (isMediumScreen(context) && medium != null) {
      return medium;
    }
    return small;
  }

  /// Responsive spacing
  /// Usage: ScreenUtil.spacing(context, base: 16)
  static double spacing(BuildContext context, {required double base}) {
    if (isSmallScreen(context)) {
      return base * 0.75; // 25% smaller on small screens
    } else if (isTablet(context)) {
      return base * 1.25; // 25% larger on tablets
    } else if (isDesktop(context)) {
      return base * 1.5; // 50% larger on desktop
    }
    return base;
  }

  /// Responsive font size
  /// Usage: ScreenUtil.fontSize(context, base: 14)
  static double fontSize(BuildContext context, {required double base}) {
    if (isSmallScreen(context)) {
      return base * 0.9; // 10% smaller
    } else if (isTablet(context)) {
      return base * 1.1; // 10% larger
    } else if (isDesktop(context)) {
      return base * 1.2; // 20% larger
    }
    return base;
  }

  /// Get grid column count based on screen size
  /// Usage: ScreenUtil.gridColumnCount(context, mobile: 2, tablet: 3, desktop: 4)
  static int gridColumnCount(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    if (isDesktop(context)) {
      return desktop;
    } else if (isTablet(context)) {
      return tablet;
    }
    return mobile;
  }

  /// Get aspect ratio based on screen orientation
  static double aspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width / size.height;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
}

/// Extension on BuildContext for responsive utilities
extension ResponsiveExtensions on BuildContext {
  /// Quick access to ScreenUtil methods
  bool get isSmallScreen => ScreenUtil.isSmallScreen(this);
  bool get isMediumScreen => ScreenUtil.isMediumScreen(this);
  bool get isTablet => ScreenUtil.isTablet(this);
  bool get isDesktop => ScreenUtil.isDesktop(this);

  double get screenWidth => ScreenUtil.screenWidth(this);
  double get screenHeight => ScreenUtil.screenHeight(this);
  Size get screenSize => ScreenUtil.screenSize(this);

  bool get isLandscape => ScreenUtil.isLandscape(this);
  bool get isPortrait => ScreenUtil.isPortrait(this);

  /// Responsive value
  T responsive<T>({
    required T small,
    T? medium,
    T? large,
    T? desktop,
  }) {
    return ScreenUtil.responsiveValue(
      this,
      small: small,
      medium: medium,
      large: large,
      desktop: desktop,
    );
  }

  /// Responsive spacing
  double spacing({required double base}) {
    return ScreenUtil.spacing(this, base: base);
  }

  /// Responsive font size
  double fontSize({required double base}) {
    return ScreenUtil.fontSize(this, base: base);
  }

  /// Grid column count
  int gridColumns({int mobile = 2, int tablet = 3, int desktop = 4}) {
    return ScreenUtil.gridColumnCount(
      this,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}
