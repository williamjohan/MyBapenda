// lib/presentation/features/va_qris/cubit/va_qris_cubit.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../domain/entities/va_qris/payment_method.dart';
import '../../../../domain/entities/va_qris/payment_nominal_check_entity.dart';
import '../../../../domain/entities/va_qris/payment_session_entity.dart';
import '../../../../domain/entities/va_qris/tax_billing_entity.dart';
import '../../../../domain/entities/va_qris/tax_period_entity.dart';
import '../../../../domain/entities/va_qris/tax_type_entity.dart';
import '../../../../domain/usecases/va_qris/va_qris_usecase.dart';
import '../logic/period_selection_logic.dart';
import 'va_qris_state.dart';

/// Satu Cubit untuk alur Create VA & QRIS. Tiap route membuat instance sendiri
/// dan mengisinya dari `extra`:
/// - layar input: [init] lalu [searchBilling]
/// - layar tagihan: [loadBilling], [togglePeriod], [checkNominal],
///   [confirmPayment]
/// - layar QRIS/VA: [startSession], [regenerateSession], [markExpired]
@injectable
class VaQrisCubit extends Cubit<VaQrisState> {
  final VaQrisUseCase _useCase;

  VaQrisCubit(this._useCase) : super(const VaQrisState());

  static const _pollInterval = Duration(seconds: 5);

  Timer? _pollTimer;
  bool _polling = false;

  // ------------------------------------------------------------ layar input

  Future<void> init() async {
    final res = await _useCase.getTaxTypes();
    if (isClosed) return;

    res.fold(
      (f) => emit(
        state.copyWith(status: VaQrisStatus.failure, errorMessage: f.message),
      ),
      (types) => emit(
        state.copyWith(
          status: VaQrisStatus.initial,
          taxTypes: types,
          selectedTaxType: types.isEmpty ? null : types.first,
          errorMessage: null,
        ),
      ),
    );
  }

  void selectTaxType(TaxTypeEntity type) {
    emit(
      state.copyWith(
        selectedTaxType: type,
        status: VaQrisStatus.initial,
        errorMessage: null,
      ),
    );
  }

  void clearError() {
    if (state.errorMessage == null) return;
    emit(state.copyWith(errorMessage: null));
  }

  Future<void> searchBilling(String referenceNumber) async {
    final type = state.selectedTaxType;
    if (type == null || state.status == VaQrisStatus.searching) return;

    emit(state.copyWith(status: VaQrisStatus.searching, errorMessage: null));

    final res = await _useCase.getBilling(
      taxTypeId: type.id,
      referenceNumber: referenceNumber,
    );
    if (isClosed) return;

    res.fold(
      (f) => emit(
        state.copyWith(status: VaQrisStatus.failure, errorMessage: f.message),
      ),
      (billing) =>
          emit(state.copyWith(status: VaQrisStatus.loaded, billing: billing)),
    );
  }

  // ---------------------------------------------------------- layar tagihan

  void loadBilling(TaxBillingEntity billing) {
    emit(
      state.copyWith(
        status: VaQrisStatus.loaded,
        billing: billing,
        selectedCount: PeriodSelectionLogic.defaultSelectedCount(
          billing.unpaidPeriods.length,
        ),
      ),
    );
  }

  void togglePeriod(int index) {
    emit(
      state.copyWith(
        selectedCount: PeriodSelectionLogic.toggle(
          selectedCount: state.selectedCount,
          index: index,
        ),
      ),
    );
  }

  /// Metode bayar yang boleh dipakai untuk total masa terpilih (batas dari
  /// API). null = cek gagal: kedua metode tetap ditawarkan, server tetap
  /// menolak nominal yang tidak diizinkan saat `bayar`.
  Future<PaymentNominalCheckEntity?> checkNominal() async {
    final total = state.selectedTotal;
    if (total <= 0 || state.confirming) return null;

    emit(state.copyWith(confirming: true));
    final res = await _useCase.checkNominal(total);
    if (isClosed) return null;
    emit(state.copyWith(confirming: false));

    return res.fold((f) {
      AppLogger.warning('Cek nominal $total gagal: $f');
      return null;
    }, (check) => check);
  }

  Future<void> confirmPayment(PaymentMethod method) async {
    final billing = state.billing;
    if (billing == null || state.selectedCount == 0 || state.confirming) {
      return;
    }

    await _createSession(
      method: method,
      taxTypeId: billing.taxTypeId,
      referenceLabel: billing.referenceLabel,
      referenceNumber: billing.referenceNumber,
      taxpayerName: billing.taxpayerName,
      periods: state.selectedPeriods,
    );
  }

  // --------------------------------------------------------- layar QRIS/VA

  void startSession(PaymentSessionEntity session) {
    emit(
      state.copyWith(
        session: session,
        sessionStatus: PaymentSessionStatus.pending,
      ),
    );
    watchPaymentStatus();
  }

  /// Tombol "Buat ulang" saat kedaluwarsa: minta kode bayar baru ke API.
  Future<void> regenerateSession() async {
    final old = state.session;
    if (old == null || state.confirming) return;

    final ok = await _createSession(
      method: old.method,
      taxTypeId: old.taxTypeId,
      referenceLabel: old.referenceLabel,
      referenceNumber: old.referenceNumber,
      taxpayerName: old.taxpayerName,
      periods: old.periods,
    );
    if (ok && !isClosed) {
      emit(state.copyWith(sessionStatus: PaymentSessionStatus.pending));
      watchPaymentStatus();
    }
  }

  /// Polling status selama kode bayar tampil. Berhenti saat lunas,
  /// kedaluwarsa, atau Cubit ditutup.
  void watchPaymentStatus() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkStatus());
  }

  /// Dipanggil onTimeout PaymentCountdownTimer agar state sinkron.
  void markExpired() {
    _pollTimer?.cancel();
    if (state.sessionStatus != PaymentSessionStatus.pending) return;
    emit(state.copyWith(sessionStatus: PaymentSessionStatus.expired));
  }

  // ---------------------------------------------------------------- helpers

  Future<bool> _createSession({
    required PaymentMethod method,
    required int taxTypeId,
    required String referenceLabel,
    required String referenceNumber,
    required String taxpayerName,
    required List<TaxPeriodEntity> periods,
  }) async {
    emit(state.copyWith(confirming: true, errorMessage: null));

    final res = await _useCase.createPayment(
      taxTypeId: taxTypeId,
      referenceLabel: referenceLabel,
      referenceNumber: referenceNumber,
      taxpayerName: taxpayerName,
      periods: periods,
      method: method,
    );
    if (isClosed) return false;

    return res.fold(
      (f) {
        emit(state.copyWith(confirming: false, errorMessage: f.message));
        return false;
      },
      (session) {
        emit(state.copyWith(confirming: false, session: session));
        return true;
      },
    );
  }

  Future<void> _checkStatus() async {
    final session = state.session;
    if (session == null ||
        state.sessionStatus != PaymentSessionStatus.pending ||
        _polling) {
      return;
    }

    _polling = true;
    final res = await _useCase.getPaymentStatus(session);
    _polling = false;
    if (isClosed || state.session != session) return;

    res.fold(
      // Gagal cek (jaringan dll) tidak menghentikan polling.
      (f) => AppLogger.warning('Cek status ${session.reference} gagal: $f'),
      (status) {
        if (!status.isPaid) return;
        _pollTimer?.cancel();
        emit(state.copyWith(sessionStatus: PaymentSessionStatus.paid));
      },
    );
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
