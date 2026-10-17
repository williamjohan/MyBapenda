// lib/presentation/features/va_qris/cubit/va_qris_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/entities/va_qris/payment_session_entity.dart';
import '../../../../domain/entities/va_qris/recent_reference_entity.dart';
import '../../../../domain/entities/va_qris/tax_billing_entity.dart';
import '../../../../domain/entities/va_qris/tax_period_entity.dart';
import '../../../../domain/entities/va_qris/tax_type_entity.dart';

part 'va_qris_state.freezed.dart';

enum VaQrisStatus { initial, searching, loaded, failure }

enum PaymentSessionStatus { pending, paid, expired }

@freezed
class VaQrisState with _$VaQrisState {
  const VaQrisState._();

  const factory VaQrisState({
    @Default(VaQrisStatus.initial) VaQrisStatus status,
    @Default(<TaxTypeEntity>[]) List<TaxTypeEntity> taxTypes,
    TaxTypeEntity? selectedTaxType,
    TaxBillingEntity? billing,

    /// `key` masa belum lunas yang dicentang; boleh yang mana saja (tidak
    /// harus berurutan).
    @Default(<String>{}) Set<String> selectedKeys,
    @Default(false) bool confirming,
    PaymentSessionEntity? session,
    @Default(PaymentSessionStatus.pending) PaymentSessionStatus sessionStatus,
    String? errorMessage,

    /// Riwayat "Terakhir dicari" (NOP saja, tanpa Reklame), terbaru dulu.
    @Default(<RecentReferenceEntity>[]) List<RecentReferenceEntity> recent,
  }) = _VaQrisState;

  /// Masa terpilih, tetap urut dari yang terlama (urutan dari API).
  List<TaxPeriodEntity> get selectedPeriods =>
      (billing?.unpaidPeriods ?? const <TaxPeriodEntity>[])
          .where((p) => selectedKeys.contains(p.key))
          .toList();

  int get selectedCount => selectedPeriods.length;

  /// Semua masa belum lunas sudah dicentang (untuk tombol "Pilih semua").
  bool get allPeriodsSelected {
    final payable = (billing?.unpaidPeriods ?? const <TaxPeriodEntity>[]).where(
      (p) => p.key != null,
    );
    return payable.isNotEmpty && selectedCount == payable.length;
  }

  // Rincian masa terpilih untuk bar total & cek nominal (nilai per masa dari API)
  int get selectedTotal => selectedPeriods.fold(0, (sum, p) => sum + p.total);
  int get selectedPrincipal =>
      selectedPeriods.fold(0, (sum, p) => sum + p.principal);
  int get selectedPenalty =>
      selectedPeriods.fold(0, (sum, p) => sum + p.penalty);
  int get selectedOther => selectedPeriods.fold(0, (sum, p) => sum + p.other);
  int get selectedDiscount =>
      selectedPeriods.fold(0, (sum, p) => sum + p.discount);
  String? get selectedOtherLabel =>
      selectedPeriods.isEmpty ? null : selectedPeriods.first.otherLabel;

  bool get isExpired => sessionStatus == PaymentSessionStatus.expired;
}
