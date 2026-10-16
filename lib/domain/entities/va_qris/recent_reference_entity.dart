import 'package:equatable/equatable.dart';

/// Nomor referensi yang tagihannya pernah berhasil dicari (riwayat
/// "Terakhir dicari", tersimpan di HP per NIP).
class RecentReferenceEntity extends Equatable {
  const RecentReferenceEntity({
    required this.taxTypeId,
    required this.taxTypeName,
    required this.referenceNumber,
    required this.name,
    required this.savedAt,
  });

  final int taxTypeId;
  final String taxTypeName;

  /// NOP berformat titik.
  final String referenceNumber;

  /// Nama objek pajak (atau nama WP bila objek kosong).
  final String name;
  final DateTime savedAt;

  @override
  List<Object?> get props => [
    taxTypeId,
    taxTypeName,
    referenceNumber,
    name,
    savedAt,
  ];
}
