import 'package:equatable/equatable.dart';
import 'payment_method.dart';
import 'tax_period_entity.dart';

/// Kode bayar QRIS / VA yang sedang ditampilkan ke wajib pajak.
///
/// [reference], [vaNumber], [qrisPayload], [total] dan [validFor] datang dari
/// API; sisanya konteks tagihan yang dipilih petugas.
class PaymentSessionEntity extends Equatable {
  const PaymentSessionEntity({
    required this.reference,
    required this.method,
    required this.taxTypeId,
    required this.referenceLabel,
    required this.referenceNumber,
    required this.taxpayerName,
    required this.periods,
    required this.createdAt,
    required this.validFor,
    required this.total,
    this.vaNumber,
    this.qrisPayload,
    this.nmid,
  });

  /// Kode bayar (= kode VA / kode QRIS), dipakai untuk cek status.
  final String reference;
  final PaymentMethod method;

  final int taxTypeId;
  final String referenceLabel;
  final String referenceNumber;
  final String taxpayerName;
  final List<TaxPeriodEntity> periods;

  final DateTime createdAt;

  /// Sisa masa berlaku menurut jam server saat kode dibuat.
  final Duration validFor;

  /// Nominal yang ditagihkan bank.
  final int total;

  final String? vaNumber;
  final String? qrisPayload;

  /// National Merchant ID QRIS dari API (kosong untuk VA).
  final String? nmid;

  /// Batas waktu kode bayar menurut jam HP (dari sisa waktu server).
  DateTime get expiresAt => createdAt.add(validFor);

  int get principalTotal => periods.fold(0, (sum, p) => sum + p.principal);
  int get penaltyTotal => periods.fold(0, (sum, p) => sum + p.penalty);
  int get otherTotal => periods.fold(0, (sum, p) => sum + p.other);
  int get discountTotal => periods.fold(0, (sum, p) => sum + p.discount);

  @override
  List<Object?> get props => [
    reference,
    method,
    taxTypeId,
    referenceLabel,
    referenceNumber,
    taxpayerName,
    periods,
    createdAt,
    validFor,
    total,
    vaNumber,
    qrisPayload,
    nmid,
  ];
}
