import 'package:fasto_qr/features/qr/data/models/qr_model.dart';
import 'package:fasto_qr/features/qr/data/repositories/qr_repository.dart';
import 'package:fasto_qr/features/qr/presentation/providers/qr_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mockQrList = <QrModel>[
  const QrModel(
    id: 'mock_001',
    bin: 970436,
    bankName: 'Vietcombank',
    bankShortName: 'VIETCOMBANK',
    accountNumber: '0123456789',
    accountName: 'Eclipse',
    amount: 100000,
    content: 'Content etc',
    background: '#18B8FF',
  ),
  const QrModel(
    id: 'mock_002',
    bin: 970422,
    bankName: 'MB Bank',
    bankShortName: 'MB BANK',
    accountNumber: '0987654321',
    accountName: 'Eclipse',
    amount: null,
    content: 'Content etc',
    background: '#8795C7',
  ),
  const QrModel(
    id: 'mock_003',
    bin: 970415,
    bankName: 'VietinBank',
    bankShortName: 'VIETINBANK',
    accountNumber: '1234567890',
    accountName: 'Eclipse',
    amount: 250000,
    content: 'Payment test',
    background: '#4F04FF',
  ),
];

class QrController extends AsyncNotifier<List<QrModel>> {
  QrRepository get _repository => ref.read(qrRepositoryProvider);

  @override
  Future<List<QrModel>> build() async {
    try {
      final result = await _repository.getAll();

      if (result.isEmpty) {
        return mockQrList;
      }

      return result;
    } catch (error, stackTrace) {
      print('QR database error: $error');
      print(stackTrace);

      return mockQrList;
    }
  }

  Future<void> createQr(QrModel qr) async {
    await _repository.create(qr);
    await refresh();
  }

  Future<QrModel?> getQrById(String id) {
    final mock = mockQrList.where((qr) => qr.id == id);
    if (mock.isNotEmpty) return Future.value(mock.first);

    return _repository.getById(id);
  }

  Future<void> updateQr(QrModel qr) async {
    await _repository.update(qr);
    await refresh();
  }

  Future<void> deleteQr(String id) async {
    await _repository.delete(id);
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final result = await _repository.getAll();
      return result.isEmpty ? mockQrList : result;
    });
  }
}
