import 'dart:typed_data';

import 'package:fasto_qr/core/constants/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class QrStyleBar extends StatefulWidget {
  const QrStyleBar({
    super.key,
    required this.onColorChanged,
    required this.onImagePicked,
    this.initialColor = _defaultColor,
  });

  final ValueChanged<Color> onColorChanged;
  final ValueChanged<Uint8List> onImagePicked;
  final Color initialColor;
  static const Color _defaultColor = Color(0xFF00A8FF);

  static const List<Color> _colors = [
    AppColors.white,
    Color(0xFF00A8FF), // xanh dương
    Color(0xFF00FF9D), // xanh lá
    Color(0xFFFF9500), // cam
  ];

  @override
  State<QrStyleBar> createState() => _QrStyleBarState();
}

class _QrStyleBarState extends State<QrStyleBar> {
  late Color _selected = widget.initialColor;
  static const int _maxBytes = 2 * 1024 * 1024; // 2MB

  Future<void> _pickImage() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png'],
    );
    if (file == null) return;

    final Uint8List bytes = await file.readAsBytes();
    if (!mounted) return;

    if (bytes.length > _maxBytes) {
      _showError('Image must be smaller than 2MB');
      return;
    }

    if (!_isJpgOrPng(bytes)) {
      _showError('Only JPG or PNG images are allowed');
      return;
    }

    widget.onImagePicked(bytes);
  }

  bool _isJpgOrPng(Uint8List bytes) {
    final isPng =
        bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
    final isJpg =
        bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF;
    return isPng || isJpg;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: AppColors.white.withValues(alpha: 0.8),
        radius: 16,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final color in QrStyleBar._colors) ...[
                  _ColorDot(
                    color: color,
                    selected: color == _selected,
                    onTap: () {
                      setState(() => _selected = color);
                      widget.onColorChanged(color);
                    },
                  ),
                  const SizedBox(width: 10),
                ],
              ],
            ),
            InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.upload_rounded,
                      color: AppColors.white,
                      size: 26,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.white : Colors.transparent,
            width: 2,
          ),
        ),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  static const double _dash = 3;
  static const double _gap = 3;
  static const double _strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + _dash), paint);
        distance += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}
