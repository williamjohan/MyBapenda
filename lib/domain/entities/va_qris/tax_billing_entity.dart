import 'package:equatable/equatable.dart';
import 'tax_period_entity.dart';

/// Tagihan pajak milik satu nomor referensi (No SKPD / NOP).
///
/// Urutan daftar ditentukan API: [unpaidPeriods] dari masa pajak TERLAMA,
/// [paidPeriods] dari yang terbaru. Masa yang dibayar boleh dipilih yang mana
/// saja (tidak harus berurutan).
class TaxBillingEntity extends Equatable {
  const TaxBillingEntity({
    required this.taxTypeId,
    required this.taxType,
    required this.referenceLabel,
    required this.referenceNumber,
    required this.npwpd,
    required this.taxpayerName,
    required this.taxpayerAddress,
    required this.objectName,
    required this.address,
    required this.unpaidPeriods,
    required this.paidPeriods,
    this.serviceNumber,
  });

  final int taxTypeId;
  final String taxType;

  /// "No SKPD" / "NOP".
  final String referenceLabel;

  /// No SKPD (Reklame) / NOP berformat (Air Tanah).
  final String referenceNumber;

  /// Reklame: no pelayanan permohonan asal SKPD.
  final String? serviceNumber;

  final String npwpd;
  final String taxpayerName;
  final String taxpayerAddress;
  final String objectName;
  final String address;

  final List<TaxPeriodEntity> unpaidPeriods;
  final List<TaxPeriodEntity> paidPeriods;

  @override
  List<Object?> get props => [
    taxTypeId,
    taxType,
    referenceLabel,
    referenceNumber,
    serviceNumber,
    npwpd,
    taxpayerName,
    taxpayerAddress,
    objectName,
    address,
    unpaidPeriods,
    paidPeriods,
  ];
}
