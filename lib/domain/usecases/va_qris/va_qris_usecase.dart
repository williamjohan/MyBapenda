import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failure.dart';
import '../../entities/va_qris/payment_method.dart';
import '../../entities/va_qris/payment_nominal_check_entity.dart';
import '../../entities/va_qris/payment_session_entity.dart';
import '../../entities/va_qris/payment_status_entity.dart';
import '../../entities/va_qris/recent_reference_entity.dart';
import '../../entities/va_qris/tax_billing_entity.dart';
import '../../entities/va_qris/tax_object_entity.dart';
import '../../entities/va_qris/tax_period_entity.dart';
import '../../entities/va_qris/tax_type_entity.dart';
import '../../repositories/va_qris/i_va_qris_repository.dart';

@lazySingleton
class VaQrisUseCase {
  final IVaQrisRepository _repository;

  VaQrisUseCase(this._repository);

  Future<Either<Failure, List<TaxTypeEntity>>> getTaxTypes() =>
      _repository.getTaxTypes();

  Future<Either<Failure, TaxObjectSearchResultEntity>> searchObjects({
    required String keyword,
    required int page,
    required int pageSize,
  }) => _repository.searchObjects(
    keyword: keyword,
    page: page,
    pageSize: pageSize,
  );

  Future<List<RecentReferenceEntity>> getRecent() => _repository.getRecent();

  Future<List<RecentReferenceEntity>> saveRecent(RecentReferenceEntity item) =>
      _repository.saveRecent(item);

  Future<void> clearRecent() => _repository.clearRecent();

  Future<Either<Failure, TaxBillingEntity>> getBilling({
    required int taxTypeId,
    required String referenceNumber,
  }) {
    return _repository.getBilling(
      taxTypeId: taxTypeId,
      referenceNumber: referenceNumber,
    );
  }

  Future<Either<Failure, PaymentNominalCheckEntity>> checkNominal(
    int nominal,
  ) => _repository.checkNominal(nominal);

  Future<Either<Failure, PaymentSessionEntity>> createPayment({
    required int taxTypeId,
    required String referenceLabel,
    required String referenceNumber,
    required String taxpayerName,
    required List<TaxPeriodEntity> periods,
    required PaymentMethod method,
  }) {
    return _repository.createPayment(
      taxTypeId: taxTypeId,
      referenceLabel: referenceLabel,
      referenceNumber: referenceNumber,
      taxpayerName: taxpayerName,
      periods: periods,
      method: method,
    );
  }

  Future<Either<Failure, PaymentStatusEntity>> getPaymentStatus(
    PaymentSessionEntity session,
  ) => _repository.getPaymentStatus(session);
}
