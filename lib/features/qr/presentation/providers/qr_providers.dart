import 'dart:async';

import 'package:fasto_qr/features/qr/controllers/qr_controller.dart';
import 'package:fasto_qr/features/qr/data/models/qr_model.dart';
import 'package:fasto_qr/features/qr/data/repositories/qr_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final qrRepositoryProvider = Provider<QrRepository>((ref) {
  return QrRepository();
});

final qrControllerProvider = AsyncNotifierProvider<QrController, List<QrModel>>(
  QrController.new,
);

final qrDetailProvider = FutureProvider.family<QrModel?, String>((
  ref,
  qrId,
) async {
  final repo = ref.watch(qrRepositoryProvider);
  return repo.getById(qrId);
});

final qrCreateProvider =
    AsyncNotifierProvider.autoDispose<QrCreateNotifier, QrModel?>(
      QrCreateNotifier.new,
    );

final qrUpdateProvider =
    AsyncNotifierProvider.autoDispose<QrUpdateNotifier, QrModel?>(
      QrUpdateNotifier.new,
    );

class QrUpdateNotifier extends AsyncNotifier<QrModel?> {
  @override
  FutureOr<QrModel?> build() => null;

  Future<void> updateQr(QrModel qr) async {
    if (state.isLoading) return;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(qrRepositoryProvider)
          .update(qr)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Database did not respond'),
          );

      ref.invalidate(qrControllerProvider);
      ref.invalidate(qrDetailProvider(qr.id));
      return qr;
    });
  }

  void reset() => state = const AsyncData(null);
}

class QrCreateNotifier extends AsyncNotifier<QrModel?> {
  @override
  FutureOr<QrModel?> build() => null;

  Future<void> create(CreateQrRequest request) async {
    if (state.isLoading) return;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final qr = QrModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        bin: request.bin,
        bankName: request.bankName,
        bankShortName: request.bankShortName,
        accountNumber: request.accountNumber,
        accountName: request.accountName,
        amount: request.amount,
        content: request.content,
        background: request.background,
      );

      await ref
          .read(qrRepositoryProvider)
          .create(qr)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Database did not respond'),
          );

      ref.invalidate(qrControllerProvider);
      return qr;
    });
  }

  void reset() => state = const AsyncData(null);
}
