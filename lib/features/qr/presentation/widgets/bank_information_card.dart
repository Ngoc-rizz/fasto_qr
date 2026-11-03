import 'dart:convert';

import 'package:fasto_qr/features/qr/presentation/widgets/app_input_field.dart';
import 'package:fasto_qr/features/qr/presentation/widgets/bank_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fasto_qr/core/constants/app_colors.dart';
import 'package:fasto_qr/shared/widgets/card_background.dart';

class BankInformationCard extends StatefulWidget {
  final TextEditingController accountNumberController;
  final TextEditingController accountHolderController;
  final ValueChanged<Map<String, dynamic>?>? onBankChanged;

  const BankInformationCard({
    super.key,
    required this.accountNumberController,
    required this.accountHolderController,
    this.onBankChanged,
  });

  @override
  State<BankInformationCard> createState() => _BankInformationCardState();
}

class _BankInformationCardState extends State<BankInformationCard> {
  late Future<List<Map<String, dynamic>>> _banksFuture;

  Map<String, dynamic>? _selectedBank;

  @override
  void initState() {
    super.initState();
    _banksFuture = _loadBanks();
  }

  Future<List<Map<String, dynamic>>> _loadBanks() async {
    final jsonString = await rootBundle.loadString('assets/banks.json');
    final decoded = jsonDecode(jsonString);

    if (decoded is! List) {
      throw const FormatException('banks.json must contain a JSON array.');
    }

    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return CardBackground(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBankDropdown(),
                  const SizedBox(height: 12),

                  AppInputField(
                    label: 'Account number',
                    underlineWidth: 140,
                    controller: widget.accountNumberController,
                    hint: 'Enter account number',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 12),

                  AppInputField(
                    label: 'Account holder',
                    underlineWidth: 140,
                    controller: widget.accountHolderController,
                    hint: 'Enter account holder',
                    textCapitalization: TextCapitalization.characters,
                  ),
                ],
              ),
            ),

            Positioned(right: 8, top: 8, child: _circleDecoration()),

            Positioned(right: 8, bottom: 8, child: _circleDecoration()),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDropdown() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _banksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppFieldContainer(
            label: 'Bank',
            underlineWidth: 140,
            child: const SizedBox(
              height: 24,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return AppFieldContainer(
            label: 'Bank',
            underlineWidth: 140,
            child: Text('Unable to load banks', style: _valueStyle),
          );
        }

        final banks = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bank',
              style: TextStyle(
                color: AppColors.white.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 2),
            InkWell(
              onTap: banks.isEmpty ? null : () => _showBankPicker(banks),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedBank?['name']?.toString() ?? 'Select bank',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _valueStyle.copyWith(
                          color: _selectedBank == null
                              ? AppColors.white.withValues(alpha: 0.55)
                              : AppColors.white,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 148,
              height: 1,
              color: AppColors.white.withValues(alpha: 0.65),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showBankPicker(List<Map<String, dynamic>> banks) async {
    final bank = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: AppColors.black50,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BankPickerSheet(
        banks: banks,
        selectedBin: _selectedBank?['bin']?.toString(),
      ),
    );

    if (bank == null || !mounted) return;

    setState(() => _selectedBank = bank);
    widget.onBankChanged?.call(bank);
  }

  TextStyle get _valueStyle => const TextStyle(
    color: AppColors.white,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
  );

  Widget _circleDecoration() {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.7),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.white.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}
