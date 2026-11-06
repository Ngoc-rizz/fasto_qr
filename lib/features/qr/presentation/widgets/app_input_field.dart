import 'package:fasto_qr/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const TextStyle appValueStyle = TextStyle(
  color: AppColors.white,
  fontSize: 12,
  fontWeight: FontWeight.bold,
  letterSpacing: 2,
);

class AppFieldContainer extends StatelessWidget {
  const AppFieldContainer({
    super.key,
    required this.label,
    required this.child,
    this.underlineWidth,
  });

  final String label;
  final Widget child;
  final double? underlineWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.85),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 2),
        child,
        const SizedBox(height: 5),
        underlineWidth == null
            ? Container(
                height: 1,
                color: AppColors.white.withValues(alpha: 0.65),
              )
            : Container(
                width: underlineWidth,
                height: 1,
                color: AppColors.white.withValues(alpha: 0.65),
              ),
      ],
    );
  }
}

class AppInputField extends StatelessWidget {
  const AppInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.inputFormatters,
    this.suffixText,
    this.underlineWidth,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffixText;
  final double? underlineWidth;

  @override
  Widget build(BuildContext context) {
    return AppFieldContainer(
      label: label,
      underlineWidth: underlineWidth,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        maxLines: 1,
        style: appValueStyle,
        cursorColor: AppColors.white,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          hintText: hint,
          hintStyle: appValueStyle.copyWith(
            color: AppColors.white.withValues(alpha: 0.55),
            fontWeight: FontWeight.w500,
          ),
          suffixText: suffixText,
          suffixStyle: appValueStyle,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
