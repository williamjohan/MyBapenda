import 'package:bapendacore/domain/entities/va_qris/tax_type_entity.dart';
import 'package:flutter/material.dart';

/// Ikon & keterangan singkat jenis pajak untuk tampilan pemilih.
/// Id mengikuti master pajak API (EnumFactory.EPajak).
extension TaxTypeVisual on TaxTypeEntity {
  IconData get icon => switch (id) {
    1 => Icons.restaurant_rounded, // Makanan & minuman
    2 => Icons.bolt_rounded, // Tenaga listrik
    3 => Icons.hotel_rounded, // Jasa perhotelan
    4 => Icons.local_parking_rounded, // Jasa parkir
    5 => Icons.theater_comedy_rounded, // Kesenian & hiburan
    6 => Icons.water_drop_rounded, // Air tanah
    7 => Icons.campaign_rounded, // Reklame
    _ => Icons.receipt_long_rounded,
  };

  /// Mis. "NOP · 18 digit" atau "No SKPD".
  String get inputHint => referenceLength == null
      ? referenceLabel
      : '$referenceLabel · $referenceLength digit';
}
