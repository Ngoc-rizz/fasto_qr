import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
final Widget child;
  final Gradient gradient;

  static const defaultGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF000000), // Black
      Color(0xFF1C1C1C),
      Color(0xFF404040),
      Color(0xFF666666),
      Color(0xFF808080), // Gray
    ],
  );

  const AppBackground({
    super.key,
    required this.child,
    this.gradient = defaultGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
        child,
      ],
    );
  }
}
