import 'package:flutter/material.dart';
import 'package:retail_control_platform/core/utils/screen_util.dart';

/// Responsive layout builder
/// Mobile (<600px) vs Tablet (>=600px) layout-г автоматаар сонгоно
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ScreenUtil.isDesktop(context) && desktop != null) {
      return desktop!;
    } else if (ScreenUtil.isTablet(context) && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

/// Responsive grid view helper
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.childAspectRatio = 1.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final columnCount = context.gridColumns(
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return GridView.count(
      crossAxisCount: columnCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: runSpacing,
      childAspectRatio: childAspectRatio,
      padding: padding,
      children: children,
    );
  }
}

/// Responsive value builder
class ResponsiveValue<T> extends StatelessWidget {
  final T mobile;
  final T? tablet;
  final T? desktop;
  final Widget Function(BuildContext context, T value) builder;

  const ResponsiveValue({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final value = context.responsive<T>(
      small: mobile,
      large: tablet,
      desktop: desktop,
    );
    return builder(context, value);
  }
}

/// Responsive padding
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double basePadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.basePadding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final padding = context.spacing(base: basePadding);
    return Padding(
      padding: EdgeInsets.all(padding),
      child: child,
    );
  }
}

/// Responsive font size text
class ResponsiveText extends StatelessWidget {
  final String text;
  final double baseFontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;

  const ResponsiveText(
    this.text, {
    super.key,
    this.baseFontSize = 14.0,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = context.fontSize(base: baseFontSize);
    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Responsive SizedBox spacer
class ResponsiveSpace extends StatelessWidget {
  final double baseSize;
  final bool isVertical;

  const ResponsiveSpace({
    super.key,
    this.baseSize = 16.0,
    this.isVertical = true,
  });

  const ResponsiveSpace.horizontal({
    super.key,
    this.baseSize = 16.0,
  }) : isVertical = false;

  @override
  Widget build(BuildContext context) {
    final size = context.spacing(base: baseSize);
    return SizedBox(
      width: isVertical ? null : size,
      height: isVertical ? size : null,
    );
  }
}
