const Map<String, String> _diacriticGroups = {
  'a': 'àáạảãâầấậẩẫăằắặẳẵ',
  'e': 'èéẹẻẽêềếệểễ',
  'i': 'ìíịỉĩ',
  'o': 'òóọỏõôồốộổỗơờớợởỡ',
  'u': 'ùúụủũưừứựửữ',
  'y': 'ỳýỵỷỹ',
  'd': 'đ',
};

final Map<String, String> _diacriticMap = {
  for (final entry in _diacriticGroups.entries)
    for (final ch in entry.value.split('')) ...{
      ch: entry.key,
      ch.toUpperCase(): entry.key.toUpperCase(),
    },
};

String removeDiacritics(String input) {
  final buffer = StringBuffer();
  for (final ch in input.split('')) {
    buffer.write(_diacriticMap[ch] ?? ch);
  }
  return buffer.toString();
}
