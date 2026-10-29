import 'package:fasto_qr/features/qr/data/models/qr_model.dart';
import 'package:fasto_qr/features/qr/data/repositories/qr_repository.dart';
import 'package:fasto_qr/features/qr/presentation/providers/qr_providers,.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QrController extends AsyncNotifier<List<QrModel>> {
  late final QrRepository _repository;

  @override
  Future<List<QrModel>> build() async {
    _repository = ref.read(qrRepositoryProvider);
    return _repository.getAll();
  }

  Future<void> createQr(QrModel qr) async {
    await _repository.create(qr);
    await refresh();
  }

  Future<QrModel?> getQrById(String id) {
    return _repository.getById(id);
  }

  Future<void> updateQr(QrModel qr) async {
    final rowsAffected = await _repository.update(qr);

    if (rowsAffected == 0) {
      throw StateError('QR code not found: ${qr.id}');
    }

    await refresh();
  }

  Future<void> deleteQr(String id) async {
    await _repository.delete(id);
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.getAll());
  }
}
