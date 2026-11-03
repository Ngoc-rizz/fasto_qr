import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AppBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<IconData> _icons = [
    Icons.layers_outlined,
    Icons.add,
    Icons.settings_outlined,
  ];

  static const List<String> labels = ['QR List', 'Create', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return Container(
      
      decoration: BoxDecoration(color: AppColors.black50),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 76,
          child: Row(
            children: List.generate(_icons.length, (index) {
              final isSelected = currentIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  splashColor: AppColors.blue.withValues(alpha: 0.12),
                  highlightColor: Colors.transparent,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Top indicator bar
                      Align(
                        alignment: Alignment.topCenter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          width: isSelected ? 58 : 0,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppColors.blue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Icon
                      Align(
                        alignment: Alignment.center,
                        child: AnimatedScale(
                          scale: isSelected ? 1.0 : 0.95,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _icons[index],
                            size: index == 1 ? 34 : 33,
                            color: isSelected
                                ? AppColors.blue
                                : AppColors.lavender,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
