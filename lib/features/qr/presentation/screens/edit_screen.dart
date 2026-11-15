import 'dart:convert';

import 'package:fasto_qr/core/constants/app_colors.dart';
import 'package:fasto_qr/features/qr/data/models/qr_model.dart';
import 'package:fasto_qr/features/qr/presentation/providers/qr_providers.dart';
import 'package:fasto_qr/features/qr/presentation/widgets/app_button.dart';
import 'package:fasto_qr/features/qr/presentation/widgets/app_input_field.dart';
import 'package:fasto_qr/features/qr/presentation/widgets/bank_information_card.dart';
import 'package:fasto_qr/features/qr/presentation/widgets/qr_preview_card.dart';
import 'package:fasto_qr/shared/widgets/app_background.dart';
import 'package:fasto_qr/shared/widgets/qr_style_bar.dart';
import 'package:fasto_qr/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditScreen extends ConsumerStatefulWidget {
  const EditScreen({super.key, this.onEdited, required this.qrId});

  final VoidCallback? onEdited;
  final String qrId;

  @override
  ConsumerState<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends ConsumerState<EditScreen> {
  late final TextEditingController _accountNumberController;
  late final TextEditingController _accountHolderController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  Map<String, dynamic>? _selectedBank;

  Uint8List? _backgroundBytes;

  bool _isFormInitialized = false;
  bool _isUpdating = false;

  int _formGeneration = 0;

  @override
  void initState() {
    super.initState();

    _accountNumberController = TextEditingController();
    _accountHolderController = TextEditingController();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    _amountController.dispose();
    _noteController.dispose();

    super.dispose();
  }

  void _populateForm(QrModel qr) {
    if (_isFormInitialized) return;

    _isFormInitialized = true;

    _accountNumberController.text = qr.accountNumber;
    _accountHolderController.text = qr.accountName ?? '';
    _amountController.text = qr.amount?.toString() ?? '';
    _noteController.text = qr.content ?? '';

    _selectedBank = {
      'bin': qr.bin.toString(),
      'name': qr.bankName,
      'short': qr.bankShortName,
    };

    if (qr.background != null && qr.background!.isNotEmpty) {
      try {
        _backgroundBytes = base64Decode(qr.background!);
      } catch (e) {
        debugPrint('Decode background failed: $e');
      }
    }

    if (mounted) {
      setState(() {
        _formGeneration++;
      });
    }
  }

  void _handleBankChanged(Map<String, dynamic>? bank) {
    setState(() {
      _selectedBank = bank;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _updateQr() async {
    FocusScope.of(context).unfocus();

    final bank = _selectedBank;
    final bin = int.tryParse(bank?['bin']?.toString() ?? '');
    final account = _accountNumberController.text.trim();
    final holder = _accountHolderController.text.trim();

    if (bank == null || bin == null || account.isEmpty || holder.isEmpty) {
      _showMessage('Please select a bank and enter account number and holder');
      return;
    }

    final amount = int.tryParse(
      _amountController.text.replaceAll('.', '').replaceAll(',', ''),
    );
    final note = _noteController.text.trim();

    final updated = QrModel(
      id: widget.qrId,
      bin: bin,
      bankName: bank['name']?.toString() ?? '',
      bankShortName: bank['short']?.toString() ?? '',
      accountNumber: account,
      accountName: holder,
      amount: (amount == null || amount <= 0) ? null : amount,
      content: note.isEmpty ? null : note,
      background: _backgroundBytes == null
          ? null
          : base64Encode(_backgroundBytes!),
    );

    await ref.read(qrUpdateProvider.notifier).updateQr(updated);
    if (!mounted) return;

    final state = ref.read(qrUpdateProvider);
    if (state.hasError) {
      _showMessage('Failed to update QR. Please try again.');
    } else if (state.value != null) {
      _showMessage('QR updated successfully');
      widget.onEdited?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrState = ref.watch(qrDetailProvider(widget.qrId));

    if (qrState.hasError) debugPrint('error: ${qrState.error}');

    ref.listen<AsyncValue<QrModel?>>(qrDetailProvider(widget.qrId), (
      previous,
      next,
    ) {
      next.whenData((qr) {
        if (qr != null && !_isFormInitialized) {
          _populateForm(qr);
        }
      });
    });

    ref.listen(qrUpdateProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        debugPrint('Update QR failed: ${next.error}');
      }
    });

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: false,
        body: SafeArea(
          child: qrState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 12),
                  const Text('Failed to load QR'),
                  const SizedBox(height: 8),
                  Text(error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(qrDetailProvider(widget.qrId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (qr) {
              if (qr == null) {
                return const Center(child: Text('QR not found'));
              }

              if (!_isFormInitialized) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_isFormInitialized) {
                    _populateForm(qr);
                  }
                });
              }

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [_buildHeader(context), _buildForm()],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 24, 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Text(
            'Edit QR',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final updateState = ref.watch(qrUpdateProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back
          BankInformationCard(
            key: ValueKey(_formGeneration),
            accountNumberController: _accountNumberController,
            accountHolderController: _accountHolderController,
            onBankChanged: _handleBankChanged,
            initialBank: _selectedBank,
          ),

          const SizedBox(height: 28),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppInputField(
                  label: 'Amount',
                  hint: 'Enter amount',
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  suffixText: 'VND',
                  inputFormatters: [ThousandsInputFormatter()],
                ),

                const SizedBox(height: 28),

                AppInputField(
                  label: 'Payment reference',
                  hint: '10-word limit',
                  controller: _noteController,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    MaxWordsInputFormatter(10),
                    LengthLimitingTextInputFormatter(25),
                  ],
                ),
                const SizedBox(height: 28),

                QrStyleBar(
                  onImagePicked: (bytes) {
                    setState(() {
                      _backgroundBytes = bytes;
                    });
                  },
                ),

                const SizedBox(height: 28),

                Padding(
                  padding: const EdgeInsets.all(32),
                  child: QrPreviewCard(
                    data: null,
                    backgroundBytes: _backgroundBytes,
                  ),
                ),
                const SizedBox(height: 24),

                AppButton(
                  label: 'Update',
                  isLoading: _isUpdating || updateState.isLoading,
                  onPressed: _updateQr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
