import 'package:dartz/dartz.dart';
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

abstract class IVaQrisRepository {
  Future<Either<Failure, List<TaxTypeEntity>>> getTaxTypes();

  /// Semua jenis pajak beserta jumlah per jenisnya; filter dilakukan di HP.
  Future<Either<Failure, TaxObjectSearchResultEntity>> searchObjects({
    required String keyword,
    required int page,
    required int pageSize,
  });

  /// Riwayat "Terakhir dicari" milik pegawai yang login, terbaru dulu.
  Future<List<RecentReferenceEntity>> getRecent();

  /// Mengembalikan riwayat terbaru setelah [item] ditaruh paling atas.
  Future<List<RecentReferenceEntity>> saveRecent(RecentReferenceEntity item);

  Future<void> clearRecent();

  Future<Either<Failure, TaxBillingEntity>> getBilling({
    required int taxTypeId,
    required String referenceNumber,
  });

  /// Metode bayar yang boleh dipakai untuk [nominal] (batas dari API).
  Future<Either<Failure, PaymentNominalCheckEntity>> checkNominal(int nominal);

  /// [periods] wajib N masa belum lunas terlama (divalidasi juga oleh API).
  Future<Either<Failure, PaymentSessionEntity>> createPayment({
    required int taxTypeId,
    required String referenceLabel,
    required String referenceNumber,
    required String taxpayerName,
    required List<TaxPeriodEntity> periods,
    required PaymentMethod method,
  });

  Future<Either<Failure, PaymentStatusEntity>> getPaymentStatus(
    PaymentSessionEntity session,
  );
}
