import 'package:flutter/services.dart';

/// Chỉ cho nhập số, tự thêm dấu chấm ngăn cách hàng nghìn.
class ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Giới hạn số từ tối đa.
class MaxWordsInputFormatter extends TextInputFormatter {
  MaxWordsInputFormatter(this.maxWords);

  final int maxWords;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final words = newValue.text.trim().split(RegExp(r'\s+'));
    final hasTrailingSpace = newValue.text.endsWith(' ');

    // Đã đủ số từ mà còn gõ thêm từ mới (sau dấu cách) thì chặn
    if (words.length > maxWords ||
        (words.length == maxWords && hasTrailingSpace)) {
      return oldValue;
    }
    return newValue;
  }
}
