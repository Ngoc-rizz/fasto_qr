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
