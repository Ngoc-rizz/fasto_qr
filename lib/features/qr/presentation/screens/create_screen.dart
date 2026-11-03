import 'dart:typed_data';

import 'package:fasto_qr/core/constants/app_colors.dart';
import 'package:fasto_qr/features/qr/presentation/widgets/app_button.dart';
import 'package:fasto_qr/features/qr/presentation/widgets/app_input_field.dart';
import 'package:fasto_qr/features/qr/presentation/widgets/bank_information_card.dart';
import 'package:fasto_qr/features/qr/presentation/widgets/qr_preview_card.dart';
import 'package:fasto_qr/shared/widgets/qr_style_bar.dart';
import 'package:fasto_qr/utils/currency_utils.dart';
import 'package:fasto_qr/utils/validators.dart';
import 'package:fasto_qr/utils/vietqr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  late final TextEditingController _accountNumberController;
  late final TextEditingController _accountHolderController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  Map<String, dynamic>? _selectedBank;

  Color _qrColor = AppColors.white;
  Uint8List? _backgroundBytes;
  String? _qrData;

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

  void _generateQr() {
    FocusScope.of(context).unfocus();

    final bin = _selectedBank?['bin']?.toString();
    final account = _accountNumberController.text.trim();

    if (bin == null || account.isEmpty) {
      _showMessage('Please select a bank and enter account number');
      return;
    }

    final amount = int.tryParse(_amountController.text.replaceAll('.', ''));
    final note = removeDiacritics(_noteController.text.trim());

    setState(() {
      _qrData = buildVietQr(
        bin: bin,
        accountNumber: account,
        amount: amount,
        note: note,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BankInformationCard(
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
                  onColorChanged: (color) => setState(() => _qrColor = color),
                  onImagePicked: (bytes) =>
                      setState(() => _backgroundBytes = bytes as Uint8List?),
                ),

                const SizedBox(height: 28),
                QrPreviewCard(
                  data: _qrData,
                  qrColor: _qrColor,
                  backgroundBytes: _backgroundBytes,
                ),

                const SizedBox(height: 24),

                SizedBox(height: 48),
                AppButton(label: 'Create', onPressed: _generateQr),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
