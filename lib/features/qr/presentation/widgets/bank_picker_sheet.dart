import 'package:fasto_qr/core/constants/app_colors.dart';
import 'package:fasto_qr/utils/validators.dart';
import 'package:flutter/material.dart';

class BankPickerSheet extends StatefulWidget {
  const BankPickerSheet({super.key, required this.banks, this.selectedBin});

  final List<Map<String, dynamic>> banks;
  final String? selectedBin;

  @override
  State<BankPickerSheet> createState() => _BankPickerSheetState();
}

class _BankPickerSheetState extends State<BankPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredBanks {
    final keyword = removeDiacritics(_query.trim()).toLowerCase();
    if (keyword.isEmpty) return widget.banks;

    return widget.banks.where((bank) {
      final name = removeDiacritics(bank['name']?.toString() ?? '')
          .toLowerCase();
      final shortName = removeDiacritics(bank['shortName']?.toString() ?? '')
          .toLowerCase();
      final bin = (bank['bin']?.toString() ?? '').toLowerCase();

      return name.contains(keyword) ||
          shortName.contains(keyword) ||
          bin.contains(keyword);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredBanks;
    final height = MediaQuery.sizeOf(context).height * 0.75;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SizedBox(
          height: height,
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select bank',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.white),
                cursorColor: AppColors.blue,
                textInputAction: TextInputAction.search,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search bank name or code',
                  hintStyle: const TextStyle(color: AppColors.white50),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.white50,
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.white50,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                  filled: true,
                  fillColor: AppColors.white.withValues(alpha: 0.08),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No banks found',
                          style: TextStyle(color: AppColors.white50),
                        ),
                      )
                    : ListView.separated(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => Divider(
                          color: AppColors.white.withValues(alpha: 0.12),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final bank = filtered[index];
                          final isSelected =
                              widget.selectedBin == bank['bin']?.toString();

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              bank['name']?.toString() ?? '',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              bank['shortName']?.toString() ?? '',
                              style: const TextStyle(color: AppColors.white50),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AppColors.blue,
                                  )
                                : null,
                            // Trả ngân hàng về cho nơi gọi
                            onTap: () => Navigator.pop(context, bank),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
