import 'package:mybapenda/domain/entities/va_qris/tax_type_entity.dart';
import 'package:flutter/material.dart';

/// Ikon jenis pajak berdasarkan id master pajak API (EnumFactory.EPajak).
/// Dipakai juga oleh hasil "Cari objek pajak" & riwayat yang hanya membawa id.
IconData taxTypeIcon(int id) => switch (id) {
  1 => Icons.restaurant_rounded, // Makanan & minuman
  2 => Icons.bolt_rounded, // Tenaga listrik
  3 => Icons.hotel_rounded, // Jasa perhotelan
  4 => Icons.local_parking_rounded, // Jasa parkir
  5 => Icons.theater_comedy_rounded, // Kesenian & hiburan
  6 => Icons.water_drop_rounded, // Air tanah
  7 => Icons.campaign_rounded, // Reklame
  _ => Icons.receipt_long_rounded,
};

/// Nama pendek jenis pajak untuk chip di daftar objek pajak (nama master
/// PBJT terlalu panjang untuk chip). Id tak dikenal pakai [fallback].
String taxTypeShortName(int id, {String fallback = ''}) => switch (id) {
  1 => 'Resto',
  2 => 'Listrik',
  3 => 'Hotel',
  4 => 'Parkir',
  5 => 'Hiburan',
  6 => 'Air Tanah',
  7 => 'Reklame',
  _ => fallback,
};

/// Ikon & keterangan singkat jenis pajak untuk tampilan pemilih.
extension TaxTypeVisual on TaxTypeEntity {
  IconData get icon => taxTypeIcon(id);

  /// Mis. "NOP · 18 digit" atau "No SKPD".
  String get inputHint => referenceLength == null
      ? referenceLabel
      : '$referenceLabel · $referenceLength digit';
}
