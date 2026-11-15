import 'dart:convert';
import 'dart:typed_data';

import 'package:fasto_qr/core/constants/app_colors.dart';
import 'package:fasto_qr/features/qr/data/models/qr_model.dart';
import 'package:fasto_qr/features/qr/presentation/providers/qr_providers.dart';
import 'package:fasto_qr/features/qr/presentation/screens/edit_screen.dart';
import 'package:fasto_qr/shared/widgets/card_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DetailScreen extends ConsumerWidget {
  final String qrId;

  const DetailScreen({super.key, required this.qrId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrState = ref.watch(qrDetailProvider(qrId));

    return Scaffold(
      backgroundColor: const Color(0xFF123A50),
      body: Stack(
        fit: StackFit.expand,
        children: [
          qrState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unable to load QR details'),
                  TextButton(
                    onPressed: () => ref.invalidate(qrDetailProvider(qrId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (qr) => qr == null
                ? const Center(child: Text('QR not found'))
                : QrDetailContent(
                    qr: qr,
                    onEdit: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditScreen(
                            qrId: qr.id,
                            onEdited: () => Navigator.of(context).pop(),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: AppColors.white,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QrDetailContent extends StatelessWidget {
  final QrModel qr;
  final VoidCallback? onEdit;
  final VoidCallback? onDownload;

  const QrDetailContent({
    super.key,
    required this.qr,
    this.onEdit,
    this.onDownload,
  });
  @override
  Widget build(BuildContext context) {
    final bytes = _bgBytes();

    return Stack(
      fit: StackFit.expand,
      children: [
        if (bytes != null)
          AnimatedOpacity(
            opacity: 0.6,
            duration: const Duration(milliseconds: 300),
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          )
        else
          const ColoredBox(color: Color(0xFF123A50)),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 58, vertical: 24),
            child: Column(
              children: [
                const SizedBox(height: 80),
                CardBackground(
                  colors: [
                    AppColors.white.withValues(alpha: 0.2),
                    AppColors.black.withValues(alpha: 0.8),
                  ],

                  borderRadius: BorderRadius.circular(16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 28,
                  ),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final qrSize = c.maxWidth * 0.75;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 32,
                        children: [
                          QrImageView(
                            data: _buildQrData(),
                            size: qrSize,
                            backgroundColor: Colors.transparent,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppColors.white,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: AppColors.white,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 12,
                            children: [
                              Text(
                                qr.accountName ?? 'Unknown account',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Container(
                                width: 44,
                                height: 1,
                                color: AppColors.white,
                              ),
                              Text(
                                qr.content ?? 'Payment QR',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 70),
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(label: 'Edit', onPressed: onEdit),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      child: _actionButton(
                        label: 'Download QR',
                        onPressed: onDownload,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _buildQrData() {
    return 'BANK:$qr.bin|ACCOUNT:${qr.accountNumber}'
        '|AMOUNT:${qr.amount ?? 0}|CONTENT:${qr.content ?? ''}';
  }

  Uint8List? _bgBytes() {
    final b64 = qr.background;
    if (b64 == null || b64.isEmpty) return null;
    try {
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }

  Widget _actionButton({required String label, VoidCallback? onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.white,
        backgroundColor: AppColors.black.withValues(alpha: 0.12),
        side: BorderSide(color: AppColors.white),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: AppColors.white,
        ),
      ),
    );
  }
}
