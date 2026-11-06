import 'package:fasto_qr/core/constants/app_colors.dart';
import 'package:fasto_qr/features/qr/data/models/qr_model.dart';
import 'package:fasto_qr/shared/widgets/card_background.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrItem extends StatelessWidget {
  final QrModel qr;
  final VoidCallback? onTap;
  final VoidCallback? onInfoTap;
  final bool isExpanded;

  const QrItem({
    super.key,
    required this.qr,
    this.onTap,
    this.onInfoTap,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return CardBackground(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                const Icon(
                  Icons.radio_button_checked,
                  size: 15,
                  color: AppColors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    qr.bankShortName.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onInfoTap,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.info_outline,
                      size: 19,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            sizeCurve: Curves.easeInOut,
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: _buildCompactContent(),
            secondChild: _buildExpandedContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactContent() {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          children: [
            Expanded(child: _infoText(qr.accountName ?? 'Eclipse')),
            Container(
              width: 1,
              height: 22,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: AppColors.white50,
            ),
            Expanded(child: _infoText(qr.content ?? 'Content etc')),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.only(top: 14, left: 28, bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          QrImageView(
            data: _buildQrData(),
            size: 100,
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AppColors.white,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoText(qr.accountName ?? 'Eclipse'),
                const SizedBox(height: 14),
                _infoText(qr.content ?? 'Content etc'),
                const SizedBox(height: 10),
                _infoText(qr.accountNumber),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoText(String text) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.3,
      ),
    );
  }

  String _buildQrData() {
    return 'BANK:$qr.bin|ACCOUNT:${qr.accountNumber}'
        '|AMOUNT:${qr.amount ?? 0}|CONTENT:${qr.content ?? ''}';
  }
}
