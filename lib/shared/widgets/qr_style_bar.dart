import 'dart:typed_data';

import 'package:fasto_qr/core/constants/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class QrStyleBar extends StatefulWidget {
  const QrStyleBar({super.key, required this.onImagePicked});

  final ValueChanged<Uint8List> onImagePicked;

  @override
  State<QrStyleBar> createState() => _QrStyleBarState();
}

class _QrStyleBarState extends State<QrStyleBar> {
  static const int _maxBytes = 2 * 1024 * 1024;

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
        color: AppColors.white50.withValues(alpha: 0.8),
        radius: 12,
      ),
      child: Material(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(16),
          child: const SizedBox(
            width: double.infinity,
            height: 56,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  Icon(Icons.upload_rounded, color: AppColors.white, size: 24),
                  Text(
                    'Upload image',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
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
