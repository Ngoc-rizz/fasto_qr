import 'dart:convert';

import 'package:fasto_qr/core/constants/app_colors.dart';
import 'package:fasto_qr/features/qr/data/models/qr_model.dart';
import 'package:fasto_qr/features/qr/presentation/providers/qr_providers.dart';
import 'package:fasto_qr/features/qr/presentation/widgets/app_button.dart';
import 'package:fasto_qr/features/qr/presentation/widgets/app_input_field.dart';
import 'package:fasto_qr/features/qr/presentation/widgets/bank_information_card.dart';
import 'package:fasto_qr/features/qr/presentation/widgets/qr_preview_card.dart';
import 'package:fasto_qr/shared/widgets/qr_style_bar.dart';
import 'package:fasto_qr/utils/currency_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key, this.onCreated});
  final VoidCallback? onCreated;

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  late final TextEditingController _accountNumberController;
  late final TextEditingController _accountHolderController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  final ScrollController _scrollController = ScrollController();

  Map<String, dynamic>? _selectedBank;

  Uint8List? _backgroundBytes;

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
    _scrollController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int _formGeneration = 0;

  void _handleBankChanged(Map<String, dynamic>? bank) {
    setState(() {
      _selectedBank = bank;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _generateQr() async {
    FocusScope.of(context).unfocus();

    final bank = _selectedBank;
    final bin = int.tryParse(bank?['bin']?.toString() ?? '');
    final account = _accountNumberController.text.trim();
    final holder = _accountHolderController.text.trim();
    if (bank == null || bin == null || account.isEmpty || holder.isEmpty) {
      _showMessage('Please select a bank and enter account number and holder');
      return;
    }

    final amount = int.tryParse(_amountController.text.replaceAll('.', ''));
    final note = _noteController.text.trim();

    final request = CreateQrRequest(
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

    await ref.read(qrCreateProvider.notifier).create(request);

    if (!mounted) return;

    final state = ref.read(qrCreateProvider);
    if (!state.hasError && state.value != null) {
      _resetForm();

      widget.onCreated?.call();
    }
  }

  Future<void> _handleRefresh() async {
    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<QrModel?>>(qrCreateProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        _showMessage('Failed to create QR. Please try again.');
      } else if (next.value != null && previous?.value != next.value) {
        _showMessage('QR saved');
      }
    });

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.white,
      backgroundColor: const Color(0xFF123A50),
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [_buildHeader(context), _buildForm()],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Row(
        children: [
          const Icon(Icons.qr_code_2_rounded, color: AppColors.white, size: 28),
          const SizedBox(width: 10),
          Text(
            'Create QR',
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
    final createState = ref.watch(qrCreateProvider);
    final qr = createState.value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BankInformationCard(
            key: ValueKey(_formGeneration),
            accountNumberController: _accountNumberController,
            accountHolderController: _accountHolderController,
            onBankChanged: _handleBankChanged,
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
                  onImagePicked: (bytes) =>
                      setState(() => _backgroundBytes = bytes),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: QrPreviewCard(
                    data: qr?.vietQrPayload,
                    backgroundBytes: _backgroundBytes,
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Create',
                  isLoading: createState.isLoading,
                  onPressed: _generateQr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _accountNumberController.clear();
      _accountHolderController.clear();
      _amountController.clear();
      _noteController.clear();

      _selectedBank = null;
      _backgroundBytes = null;
      _formGeneration++;
    });

    // Xóa QR cũ trong provider.
    ref.invalidate(qrCreateProvider);
  }
}
