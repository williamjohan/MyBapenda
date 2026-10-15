import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/failure.dart';
import '../../../core/network/safe_api_call.dart';
import '../../../domain/entities/va_qris/payment_method.dart';
import '../../../domain/entities/va_qris/payment_nominal_check_entity.dart';
import '../../../domain/entities/va_qris/payment_session_entity.dart';
import '../../../domain/entities/va_qris/payment_status_entity.dart';
import '../../../domain/entities/va_qris/tax_billing_entity.dart';
import '../../../domain/entities/va_qris/tax_period_entity.dart';
import '../../../domain/entities/va_qris/tax_type_entity.dart';
import '../../../domain/repositories/va_qris/i_va_qris_repository.dart';
import '../../datasources/va_qris/va_qris_remote_datasource.dart';
import '../../models/va_qris/payment_nominal_check_model.dart';
import '../../models/va_qris/payment_session_model.dart';
import '../../models/va_qris/payment_status_model.dart';
import '../../models/va_qris/tax_billing_model.dart';
import '../../models/va_qris/tax_type_model.dart';

@LazySingleton(as: IVaQrisRepository)
class VaQrisRepositoryImpl implements IVaQrisRepository {
  final IVaQrisRemoteDataSource _remoteDataSource;

  VaQrisRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<TaxTypeEntity>>> getTaxTypes() {
    return executeSafeApiCall<List<TaxTypeEntity>>(() async {
      final models = await _remoteDataSource.getTaxTypes();
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, TaxBillingEntity>> getBilling({
    required int taxTypeId,
    required String referenceNumber,
  }) {
    return executeSafeApiCall<TaxBillingEntity>(() async {
      final model = await _remoteDataSource.getBilling(
        taxTypeId: taxTypeId,
        referenceNumber: referenceNumber,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, PaymentNominalCheckEntity>> checkNominal(int nominal) {
    return executeSafeApiCall<PaymentNominalCheckEntity>(() async {
      final model = await _remoteDataSource.checkNominal(nominal);
      return model.toEntity();
    });
  }

  @override
  Future<Either<Failure, PaymentSessionEntity>> createPayment({
    required int taxTypeId,
    required String referenceLabel,
    required String referenceNumber,
    required String taxpayerName,
    required List<TaxPeriodEntity> periods,
    required PaymentMethod method,
  }) {
    return executeSafeApiCall<PaymentSessionEntity>(() async {
      final model = await _remoteDataSource.createPayment(
        CreatePaymentRequestModel(
          jenisPajak: taxTypeId,
          noReferensi: referenceNumber,
          tipePembayaran: method.apiValue,
          keyTagihan: [
            for (final p in periods)
              if (p.key != null) p.key!,
          ],
        ),
      );
      return model.toEntity(
        method: method,
        taxTypeId: taxTypeId,
        referenceLabel: referenceLabel,
        taxpayerName: taxpayerName,
        periods: periods,
      );
    });
  }

  @override
  Future<Either<Failure, PaymentStatusEntity>> getPaymentStatus(
    PaymentSessionEntity session,
  ) {
    return executeSafeApiCall<PaymentStatusEntity>(() async {
      final model = await _remoteDataSource.getPaymentStatus(
        method: session.method.apiValue,
        paymentCode: session.reference,
      );
      return model.toEntity();
    });
  }
}
