String buildVietQr({
  required String bin,
  required String accountNumber,
  int? amount,
  String? note,
}) {
  String f(String id, String value) =>
      '$id${value.length.toString().padLeft(2, '0')}$value';

  final hasAmount = amount != null && amount > 0;
  final hasNote = note != null && note.isNotEmpty;

  final merchantInfo = f(
    '38',
    f('00', 'A000000727') +
        f('01', f('00', bin) + f('01', accountNumber)) +
        f('02', 'QRIBFTTA'),
  );

  final buffer = StringBuffer()
    ..write(f('00', '01'))
    ..write(f('01', hasAmount ? '12' : '11'))
    ..write(merchantInfo)
    ..write(f('53', '704'));

  if (hasAmount) buffer.write(f('54', amount.toString()));
  buffer.write(f('58', 'VN'));
  if (hasNote) buffer.write(f('62', f('08', note)));

  final withoutCrc = '${buffer}6304';
  return withoutCrc + _crc16(withoutCrc);
}

String _crc16(String input) {
  var crc = 0xFFFF;
  for (final unit in input.codeUnits) {
    crc ^= unit << 8;
    for (var i = 0; i < 8; i++) {
      crc = (crc & 0x8000) != 0 ? (crc << 1) ^ 0x1021 : crc << 1;
      crc &= 0xFFFF;
    }
  }
  return crc.toRadixString(16).toUpperCase().padLeft(4, '0');
}
