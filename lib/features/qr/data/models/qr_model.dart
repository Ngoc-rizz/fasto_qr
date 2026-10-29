class QrModel {
  final String id;
  final int bin;
  final String bankName;
  final String bankShortName;
  final String accountNumber;
  final String? accountName;
  final int? amount;
  final String? content;
  final String? background;

  const QrModel({
    required this.id,
    required this.bin,
    required this.bankName,
    required this.bankShortName,
    required this.accountNumber,
    this.accountName,
    this.amount,
    this.content,
    this.background,
  });

  factory QrModel.fromMap(Map<String, Object?> map) {
    return QrModel(
      id: map['id'] as String,
      bin: map['bin'] as int,
      bankName: map['bank_name'] as String,
      bankShortName: map['bank_short_name'] as String,
      accountNumber: map['account_number'] as String,
      accountName: map['account_name'] as String?,
      amount: map['amount'] as int?,
      content: map['content'] as String?,
      background: map['background'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'bin': bin,
      'bank_name': bankName,
      'bank_short_name': bankShortName,
      'account_number': accountNumber,
      'account_name': accountName,
      'amount': amount,
      'content': content,
      'background': background,
    };
  }
}
