import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final Gradient gradient;

  static const defaultGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF40C4A0),
      Color(0xFF2DBEBE),
      Color(0xFF1E96A0),
      Color(0xFF1E6EAA),
      Color(0xFF195AAA),
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
