import 'dart:typed_data';

import 'package:fasto_qr/core/constants/app_colors.dart';
import 'package:fasto_qr/shared/widgets/card_background.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPreviewCard extends StatelessWidget {
  const QrPreviewCard({
    super.key,
    required this.qrColor,
    this.data, // null = chưa tạo, hiện QR mẫu
    this.backgroundBytes,
  });

  final String? data;
  final Color qrColor;
  final Uint8List? backgroundBytes;

  static const double _radius = 24;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: AppColors.white, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius - 1),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (backgroundBytes != null)
                Image.memory(backgroundBytes!, fit: BoxFit.cover),

              Center(
                child: FractionallySizedBox(
                  widthFactor: 0.6,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CardBackground(
                      borderRadius: BorderRadius.circular(20),
                      padding: const EdgeInsets.all(24),
                      child: data == null
                          ? FittedBox(
                              child: Icon(
                                Icons.qr_code_2_rounded,
                                color: qrColor.withValues(alpha: 0.6),
                              ),
                            )
                          : QrImageView(
                              data: data!,
                              version: QrVersions.auto,
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              errorCorrectionLevel: QrErrorCorrectLevel.M,
                              eyeStyle: QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: qrColor,
                              ),
                              dataModuleStyle: QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: qrColor,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
