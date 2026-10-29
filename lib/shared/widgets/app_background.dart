import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final String? imagePath;
  final BoxFit fit;
  final Color? overlayColor;

  const AppBackground({
    super.key,
    required this.child,
    this.imagePath = 'assets/images/app_background.jpg',
    this.fit = BoxFit.cover,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (imagePath != null)
          Image.asset(
            imagePath!,
            fit: fit,
            errorBuilder: (_, __, ___) {
              return const ColoredBox(color: AppColors.black);
            },
          )
        else
          const ColoredBox(color: AppColors.black),

        if (overlayColor != null) ColoredBox(color: overlayColor!),

        child,
      ],
    );
  }
}
