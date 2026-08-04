import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final double borderOpacity;
  final double bgOpacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<Color>? gradientColors;
  final BoxBorder? customBorder;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 24.0,
    this.blur = 15.0,
    this.borderOpacity = 0.15,
    this.bgOpacity = 0.08,
    this.padding,
    this.margin,
    this.gradientColors,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final defaultBgColors = isDark
        ? [
            Colors.white.withOpacity(bgOpacity),
            Colors.white.withOpacity(bgOpacity * 0.4),
          ]
        : [
            Colors.white.withOpacity(bgOpacity * 1.5),
            Colors.white.withOpacity(bgOpacity * 0.6),
          ];

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors ?? defaultBgColors,
              ),
              border: customBorder ??
                  Border.all(
                    width: 1.2,
                    color: (isDark ? Colors.white : Colors.black).withOpacity(borderOpacity),
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
