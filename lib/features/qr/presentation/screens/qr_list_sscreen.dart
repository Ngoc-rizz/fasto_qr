import 'package:fasto_qr/core/constants/app_colors.dart';
import 'package:fasto_qr/features/qr/data/models/qr_model.dart';
import 'package:fasto_qr/features/qr/presentation/providers/qr_providers.dart';
import 'package:fasto_qr/features/qr/presentation/screens/detail_screen.dart';
import 'package:fasto_qr/features/qr/presentation/widgets/qr_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QrListScreen extends ConsumerStatefulWidget {
  const QrListScreen({super.key});

  @override
  ConsumerState<QrListScreen> createState() => _QrListScreenState();
}

class _QrListScreenState extends ConsumerState<QrListScreen> {
  String? _expandedQrId;

  void _showDetail(BuildContext context, QrModel qr) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(qrId: qr.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qrState = ref.watch(qrControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: qrState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.blue),
                ),
                error: (error, stackTrace) => _buildError(context, ref, error),
                data: (qrList) {
                  if (qrList.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return RefreshIndicator(
                    color: AppColors.blue,
                    onRefresh: () {
                      return ref.read(qrControllerProvider.notifier).refresh();
                    },
                    child: _buildQrList(qrList),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.qr_code_2_sharp,
                  color: AppColors.white,
                  size: 28,
                ),
                SizedBox(width: 10),
                Text(
                  'QR CODES',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrList(List<QrModel> qrList) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: qrList.length,
      separatorBuilder: (_, _) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final qr = qrList[index];
        final isExpanded = _expandedQrId == qr.id;

        return QrItem(
          key: ValueKey(qr.id),
          qr: qr,
          isExpanded: isExpanded,
          onTap: () {
            setState(() {
              _expandedQrId = isExpanded ? null : qr.id;
            });
          },
          onInfoTap: () {
            _showDetail(context, qr);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2, size: 76, color: AppColors.white50),
            const SizedBox(height: 20),
            const Text(
              'No QR codes yet',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first payment QR to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.75),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.orange),
            const SizedBox(height: 12),
            const Text(
              'Unable to load QR codes',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.white50, fontSize: 12),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref.invalidate(qrControllerProvider);
              },
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
