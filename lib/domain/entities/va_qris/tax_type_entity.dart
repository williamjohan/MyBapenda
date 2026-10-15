import 'package:equatable/equatable.dart';

/// Jenis pajak yang bisa ditagih beserta aturan input nomor referensinya.
/// Seluruh nilai datang dari API (`/api/pembayaran/jenis-pajak`).
class TaxTypeEntity extends Equatable {
  const TaxTypeEntity({
    required this.id,
    required this.name,
    required this.referenceLabel,
    required this.hint,
    required this.digitsOnly,
    this.referenceLength,
    this.mask,
  });

  final int id;
  final String name;

  /// Label field input, mis. "No SKPD" / "NOP".
  final String referenceLabel;
  final String hint;

  /// true = keyboard angka.
  final bool digitsOnly;

  /// Panjang wajib tanpa pemisah; null = bebas.
  final int? referenceLength;

  /// Pola tampilan input dari API (`#` = 1 digit), mis. NOP
  /// "##.##.###.###.###.#####". null = input bebas (No SKPD).
  final String? mask;

  @override
  List<Object?> get props => [
    id,
    name,
    referenceLabel,
    hint,
    digitsOnly,
    referenceLength,
    mask,
  ];
}
