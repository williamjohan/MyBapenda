import 'package:flutter/services.dart';

/// Memformat input mengikuti pola dari API: `#` = 1 digit, karakter lain
/// (mis. titik) ditambahkan otomatis. Pemisah yang diketik / ditempel sendiri
/// diabaikan, jadi "357801000190200001" dan "35.78.010.001.902.00001" sama-sama
/// menjadi "35.78.010.001.902.00001". Jumlah digit dibatasi jumlah `#`.
class ReferenceMaskFormatter extends TextInputFormatter {
  ReferenceMaskFormatter(this.mask) : _maxDigits = '#'.allMatches(mask).length;

  final String mask;
  final int _maxDigits;

  static String digitsOf(String text) => text.replaceAll(RegExp(r'\D'), '');

  String apply(String text) {
    final digits = digitsOf(text);
    final limited = digits.length > _maxDigits
        ? digits.substring(0, _maxDigits)
        : digits;

    final buffer = StringBuffer();
    var i = 0;
    for (final char in mask.split('')) {
      if (i >= limited.length) break;
      if (char == '#') {
        buffer.write(limited[i]);
        i++;
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Hapus tepat di belakang pemisah: ikut hapus digit sebelumnya
    var text = newValue.text;
    final deletedSeparator =
        oldValue.text.length - newValue.text.length == 1 &&
        digitsOf(oldValue.text) == digitsOf(newValue.text);
    if (deletedSeparator) {
      final digits = digitsOf(text);
      text = digits.isEmpty ? '' : digits.substring(0, digits.length - 1);
    }

    final formatted = apply(text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
