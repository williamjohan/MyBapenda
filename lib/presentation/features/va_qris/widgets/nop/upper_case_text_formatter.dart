import 'package:flutter/services.dart';

/// Memaksa input jadi huruf kapital (mis. No SKPD), termasuk teks yang
/// ditempel. `textCapitalization` saja hanya menyalakan Shift di keyboard.
/// Posisi kursor dipertahankan selama panjang teks tetap.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final upper = newValue.text.toUpperCase();
    if (upper == newValue.text) return newValue;
    // Jaga-jaga bila konversi kapital mengubah panjang: kursor ke akhir.
    if (upper.length != newValue.text.length) {
      return TextEditingValue(
        text: upper,
        selection: TextSelection.collapsed(offset: upper.length),
      );
    }
    return newValue.copyWith(text: upper);
  }
}
