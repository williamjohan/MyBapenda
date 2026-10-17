import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/errors/exception.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/base_api/base_api_response_model.dart';
import '../../models/va_qris/payment_nominal_check_model.dart';
import '../../models/va_qris/payment_session_model.dart';
import '../../models/va_qris/payment_status_model.dart';
import '../../models/va_qris/tax_billing_model.dart';
import '../../models/va_qris/tax_object_model.dart';
import '../../models/va_qris/tax_type_model.dart';

abstract class IVaQrisRemoteDataSource {
  Future<List<TaxTypeModel>> getTaxTypes();

  /// "Cari objek pajak" berdasarkan nama / alamat / NOP (berhalaman), semua
  /// jenis pajak beserta jumlah per jenisnya.
  Future<TaxObjectSearchModel> searchObjects({
    required String keyword,
    required int page,
    required int pageSize,
  });

  Future<TaxBillingModel> getBilling({
    required int taxTypeId,
    required String referenceNumber,
  });

  Future<PaymentNominalCheckModel> checkNominal(int nominal);

  Future<PaymentSessionModel> createPayment(CreatePaymentRequestModel request);

  Future<PaymentStatusModel> getPaymentStatus({
    required String method,
    required String paymentCode,
  });
}

@LazySingleton(as: IVaQrisRemoteDataSource)
class VaQrisRemoteDataSourceImpl implements IVaQrisRemoteDataSource {
  final Dio _dio;

  VaQrisRemoteDataSourceImpl(this._dio);

  @override
  Future<List<TaxTypeModel>> getTaxTypes() async {
    final response = await _dio.get(ApiEndpoints.pembayaranJenisPajak);

    final baseResponse = BaseApiResponseModel<List<TaxTypeModel>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((e) => TaxTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

    if (!baseResponse.isSuccess) {
      throw ServerException(baseResponse.status, baseResponse.errorMessage);
    }

    return baseResponse.data ?? [];
  }

  @override
  Future<TaxObjectSearchModel> searchObjects({
    required String keyword,
    required int page,
    required int pageSize,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.pembayaranCariObjek,
      queryParameters: {'keyword': keyword, 'page': page, 'pageSize': pageSize},
    );

    final baseResponse = BaseApiResponseModel<TaxObjectSearchModel>.fromJson(
      response.data,
      (json) => TaxObjectSearchModel.fromJson(json as Map<String, dynamic>),
    );

    if (!baseResponse.isSuccess || baseResponse.data == null) {
      throw ServerException(baseResponse.status, baseResponse.errorMessage);
    }

    return baseResponse.data!;
  }

  @override
  Future<TaxBillingModel> getBilling({
    required int taxTypeId,
    required String referenceNumber,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.pembayaranTagihan,
      queryParameters: {
        'jenisPajak': taxTypeId,
        'noReferensi': referenceNumber,
      },
    );

    final baseResponse = BaseApiResponseModel<TaxBillingModel>.fromJson(
      response.data,
      (json) => TaxBillingModel.fromJson(json as Map<String, dynamic>),
    );

    if (!baseResponse.isSuccess || baseResponse.data == null) {
      throw ServerException(baseResponse.status, baseResponse.errorMessage);
    }

    return baseResponse.data!;
  }

  @override
  Future<PaymentNominalCheckModel> checkNominal(int nominal) async {
    final response = await _dio.post(
      ApiEndpoints.pembayaranCheckNominal,
      data: {'nominal': nominal},
    );

    final baseResponse =
        BaseApiResponseModel<PaymentNominalCheckModel>.fromJson(
          response.data,
          (json) =>
              PaymentNominalCheckModel.fromJson(json as Map<String, dynamic>),
        );

    if (!baseResponse.isSuccess || baseResponse.data == null) {
      throw ServerException(baseResponse.status, baseResponse.errorMessage);
    }

    return baseResponse.data!;
  }

  @override
  Future<PaymentSessionModel> createPayment(
    CreatePaymentRequestModel request,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.pembayaranBayar,
      data: request.toJson(),
    );

    final baseResponse = BaseApiResponseModel<PaymentSessionModel>.fromJson(
      response.data,
      (json) => PaymentSessionModel.fromJson(json as Map<String, dynamic>),
    );

    if (!baseResponse.isSuccess || baseResponse.data == null) {
      throw ServerException(baseResponse.status, baseResponse.errorMessage);
    }

    return baseResponse.data!;
  }

  @override
  Future<PaymentStatusModel> getPaymentStatus({
    required String method,
    required String paymentCode,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.pembayaranStatus,
      queryParameters: {'tipePembayaran': method, 'kodeBayar': paymentCode},
    );

    final baseResponse = BaseApiResponseModel<PaymentStatusModel>.fromJson(
      response.data,
      (json) => PaymentStatusModel.fromJson(json as Map<String, dynamic>),
    );

    if (!baseResponse.isSuccess || baseResponse.data == null) {
      throw ServerException(baseResponse.status, baseResponse.errorMessage);
    }

    return baseResponse.data!;
  }
}
