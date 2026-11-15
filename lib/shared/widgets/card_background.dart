import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class CardBackground extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final List<Color>? colors;

  const CardBackground({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.padding = const EdgeInsets.all(16),
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors =
        colors ??
        [
          AppColors.white.withValues(alpha: 0.4),
          AppColors.white.withValues(alpha: 0.1),
        ];
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: Border.all(color: AppColors.white50, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
