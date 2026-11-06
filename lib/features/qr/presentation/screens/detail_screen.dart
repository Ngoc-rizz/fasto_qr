import 'package:fasto_qr/core/constants/app_colors.dart';
import 'package:fasto_qr/features/qr/data/models/qr_model.dart';
import 'package:fasto_qr/features/qr/presentation/providers/qr_providers.dart';
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
      appBar: AppBar(
        title: const Text('QR Details'),
        backgroundColor: Colors.transparent,
      ),
      body: qrState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Unable to load QR details'),
              TextButton(
                onPressed: () {
                  ref.invalidate(qrDetailProvider(qrId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (qr) => QrDetailContent(qr: qr!),
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
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          qr.background ?? '',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF123A50)),
        ),

        Container(color: Colors.black.withValues(alpha: 0.25)),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                CardBackground(
                  borderRadius: BorderRadius.circular(16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QrImageView(
                        data: _buildQrData(),
                        size: 112,
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

                      const SizedBox(height: 28),

                      Text(
                        qr.accountName ?? 'Unknown account',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),

                      Container(
                        width: 44,
                        height: 1,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        color: AppColors.white,
                      ),

                      Text(
                        qr.content ?? 'Payment QR',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    Expanded(
                      child: _actionButton(label: 'Edit', onPressed: onEdit),
                    ),
                    const SizedBox(width: 24),
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

  Widget _actionButton({required String label, VoidCallback? onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.white,
        backgroundColor: AppColors.white.withValues(alpha: 0.12),
        side: BorderSide(color: AppColors.white.withValues(alpha: 0.55)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
      child: Text(label),
    );
  }
}
