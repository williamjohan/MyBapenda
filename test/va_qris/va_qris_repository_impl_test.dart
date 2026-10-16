import 'package:bapendacore/core/errors/exception.dart';
import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/data/datasources/va_qris/va_qris_local_datasource.dart';
import 'package:bapendacore/data/datasources/va_qris/va_qris_remote_datasource.dart';
import 'package:bapendacore/data/models/va_qris/payment_nominal_check_model.dart';
import 'package:bapendacore/data/models/va_qris/payment_session_model.dart';
import 'package:bapendacore/data/models/va_qris/payment_status_model.dart';
import 'package:bapendacore/data/models/va_qris/recent_reference_model.dart';
import 'package:bapendacore/data/models/va_qris/tax_billing_model.dart';
import 'package:bapendacore/data/models/va_qris/tax_object_model.dart';
import 'package:bapendacore/data/models/va_qris/tax_type_model.dart';
import 'package:bapendacore/data/repositories/va_qris/va_qris_repository_impl.dart';
import 'package:bapendacore/domain/entities/va_qris/payment_method.dart';
import 'package:bapendacore/domain/entities/va_qris/payment_session_entity.dart';
import 'package:bapendacore/domain/entities/va_qris/recent_reference_entity.dart';
import 'package:bapendacore/domain/entities/va_qris/tax_period_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDataSource implements IVaQrisRemoteDataSource {
  /// Dilempar oleh semua method bila diisi.
  Object? error;

  List<TaxTypeModel> taxTypes = [];
  TaxBillingModel? billing;
  PaymentNominalCheckModel? nominalCheck;
  PaymentSessionModel? session;
  PaymentStatusModel? status;

  final List<Object> calls = [];

  void _throwIfError() {
    if (error != null) throw error!;
  }

  @override
  Future<List<TaxTypeModel>> getTaxTypes() async {
    _throwIfError();
    return taxTypes;
  }

  @override
  Future<TaxBillingModel> getBilling({
    required int taxTypeId,
    required String referenceNumber,
  }) async {
    calls.add('$taxTypeId|$referenceNumber');
    _throwIfError();
    return billing!;
  }

  @override
  Future<PaymentNominalCheckModel> checkNominal(int nominal) async {
    calls.add(nominal);
    _throwIfError();
    return nominalCheck!;
  }

  @override
  Future<PaymentSessionModel> createPayment(
    CreatePaymentRequestModel request,
  ) async {
    calls.add(request);
    _throwIfError();
    return session!;
  }

  @override
  Future<PaymentStatusModel> getPaymentStatus({
    required String method,
    required String paymentCode,
  }) async {
    calls.add('$method|$paymentCode');
    _throwIfError();
    return status!;
  }

  TaxObjectSearchModel? objects;

  @override
  Future<TaxObjectSearchModel> searchObjects({
    required String keyword,
    required int page,
    required int pageSize,
  }) async {
    calls.add('$keyword|$page|$pageSize');
    _throwIfError();
    return objects!;
  }
}

class _FakeLocalDataSource implements IVaQrisLocalDataSource {
  /// Dilempar oleh semua method bila diisi.
  Object? error;
  List<RecentReferenceModel> items = [];
  bool cleared = false;

  @override
  Future<List<RecentReferenceModel>> getRecent() async {
    if (error != null) throw error!;
    return items;
  }

  @override
  Future<List<RecentReferenceModel>> saveRecent(
    RecentReferenceModel item,
  ) async {
    if (error != null) throw error!;
    items = [item, ...items];
    return items;
  }

  @override
  Future<void> clearRecent() async {
    if (error != null) throw error!;
    cleared = true;
  }
}

final _billingJson = <String, dynamic>{
  'jenisPajak': 6,
  'jenisPajakNama': 'Pajak Air Tanah',
  'labelReferensi': 'NOP',
  'noReferensi': '35.78.010.001.902.00001',
  'nomorPelayanan': null,
  'npwpd': 'P100',
  'namaWp': 'PT Sumber Air',
  'alamatWp': 'Jl. Pemuda 1',
  'namaObjek': 'Sumur Bor',
  'alamatObjek': 'Jl. Pemuda 1',
  'belumLunas': [
    {
      'keyTagihan': 'enc-1',
      'tahunPajak': 2026,
      'masaPajak': 9,
      'masaPajakNama': 'September 2026',
      'jatuhTempo': '2026-10-31T00:00:00',
      'bulanTerlambat': 1,
      'pokok': 100000.4,
      'sanksi': 2000,
      'lainnya': 5000,
      'lainnyaLabel': 'Jaminan Bongkar',
      'pengurang': 999.6,
      'total': 106000.8,
      'isLunas': false,
      'pembayaran': [],
    },
  ],
  'sudahLunas': [
    {
      'keyTagihan': null,
      'tahunPajak': 2026,
      'masaPajak': 8,
      'masaPajakNama': 'Agustus 2026',
      'jatuhTempo': '',
      'bulanTerlambat': 0,
      'pokok': 100000,
      'sanksi': 0,
      'lainnya': 0,
      'pengurang': 0,
      'total': 100000,
      'isLunas': true,
      'pembayaran': [
        {
          'tglBayar': '2026-09-10T10:15:00',
          'noNtpd': 'NTPD-1',
          'metodeBayar': 'QRIS',
          'jumlahBayar': 100000,
        },
      ],
    },
  ],
};

const _masaBelumLunas = TaxPeriodEntity(
  key: 'enc-1',
  year: 2026,
  month: 9,
  label: 'September 2026',
  principal: 100000,
  total: 100000,
);

const _masaTanpaKey = TaxPeriodEntity(
  year: 2026,
  month: 10,
  label: 'Oktober 2026',
  principal: 100000,
  total: 100000,
);

void main() {
  late _FakeDataSource dataSource;
  late _FakeLocalDataSource localDataSource;
  late VaQrisRepositoryImpl repository;

  setUp(() {
    dataSource = _FakeDataSource();
    localDataSource = _FakeLocalDataSource();
    repository = VaQrisRepositoryImpl(dataSource, localDataSource);
  });

  group('getTaxTypes', () {
    test('memetakan model ke entity (termasuk mask NOP)', () async {
      dataSource.taxTypes = [
        TaxTypeModel.fromJson({
          'id': 6,
          'nama': 'Pajak Air Tanah',
          'labelReferensi': 'NOP',
          'hint': 'Contoh: 35.78.010.001.902.00001',
          'panjangReferensi': 18,
          'hanyaAngka': true,
          'mask': '##.##.###.###.###.#####',
        }),
        TaxTypeModel.fromJson({
          'id': 7,
          'nama': 'Pajak Reklame',
          'labelReferensi': 'No SKPD',
        }),
      ];

      final result = await repository.getTaxTypes();

      final types = result.getOrElse(() => throw 'harus Right');
      expect(types, hasLength(2));
      expect(types[0].id, 6);
      expect(types[0].name, 'Pajak Air Tanah');
      expect(types[0].referenceLabel, 'NOP');
      expect(types[0].digitsOnly, isTrue);
      expect(types[0].referenceLength, 18);
      expect(types[0].mask, '##.##.###.###.###.#####');
      expect(types[1].hint, '');
      expect(types[1].digitsOnly, isFalse);
      expect(types[1].mask, isNull);
    });
  });

  group('getBilling', () {
    test('memetakan tagihan, nominal dibulatkan & tanggal di-parse', () async {
      dataSource.billing = TaxBillingModel.fromJson(_billingJson);

      final result = await repository.getBilling(
        taxTypeId: 6,
        referenceNumber: '35.78.010.001.902.00001',
      );

      expect(dataSource.calls.single, '6|35.78.010.001.902.00001');
      final billing = result.getOrElse(() => throw 'harus Right');
      expect(billing.taxTypeId, 6);
      expect(billing.taxType, 'Pajak Air Tanah');
      expect(billing.referenceLabel, 'NOP');
      expect(billing.serviceNumber, isNull);
      expect(billing.taxpayerName, 'PT Sumber Air');
      expect(billing.objectName, 'Sumur Bor');

      final unpaid = billing.unpaidPeriods.single;
      expect(unpaid.key, 'enc-1');
      expect(unpaid.label, 'September 2026');
      expect(unpaid.dueDate, DateTime(2026, 10, 31));
      expect(unpaid.lateMonths, 1);
      expect(unpaid.principal, 100000);
      expect(unpaid.penalty, 2000);
      expect(unpaid.hasPenalty, isTrue);
      expect(unpaid.other, 5000);
      expect(unpaid.otherLabel, 'Jaminan Bongkar');
      expect(unpaid.discount, 1000);
      expect(unpaid.total, 106001);
      expect(unpaid.isPaid, isFalse);
      expect(unpaid.paidAt, isNull);

      final paid = billing.paidPeriods.single;
      expect(paid.key, isNull);
      expect(paid.dueDate, isNull);
      expect(paid.hasPenalty, isFalse);
      expect(paid.isPaid, isTrue);
      expect(paid.paidAt, DateTime(2026, 9, 10, 10, 15));
    });

    test('ServerException → ServerFailure dengan pesan dari API', () async {
      dataSource.error = const ServerException(404, 'NOP tidak ditemukan');

      final result = await repository.getBilling(
        taxTypeId: 6,
        referenceNumber: '35.78.010.001.902.00009',
      );

      expect(
        result,
        const Left<Failure, dynamic>(ServerFailure('NOP tidak ditemukan')),
      );
    });
  });

  group('checkNominal', () {
    test('memetakan izin VA & QRIS', () async {
      dataSource.nominalCheck = PaymentNominalCheckModel.fromJson({
        'va': {'isAllow': true, 'message': ''},
        'qris': {'isAllow': false, 'message': 'Maksimal Rp10.000.000'},
      });

      final result = await repository.checkNominal(12000000);

      expect(dataSource.calls.single, 12000000);
      final check = result.getOrElse(() => throw 'harus Right');
      expect(check.vaAllowed, isTrue);
      expect(check.vaMessage, '');
      expect(check.qrisAllowed, isFalse);
      expect(check.qrisMessage, 'Maksimal Rp10.000.000');
    });
  });

  group('createPayment', () {
    test('kirim request sesuai API & gabungkan konteks tagihan', () async {
      dataSource.session = PaymentSessionModel.fromJson({
        'tipePembayaran': 'va',
        'noReferensi': '35.78.010.001.902.00001',
        'kodeBayar': 'VA123',
        'nominalTotal': 100000.0,
        'expiredDate': '2026-10-15T10:00:00',
        'sisaDetik': 900,
        'kodeVa': '8812345678',
      });

      final result = await repository.createPayment(
        taxTypeId: 6,
        referenceLabel: 'NOP',
        referenceNumber: '35.78.010.001.902.00001',
        taxpayerName: 'PT Sumber Air',
        periods: const [_masaBelumLunas, _masaTanpaKey],
        method: PaymentMethod.vaBankJatim,
      );

      final request = dataSource.calls.single as CreatePaymentRequestModel;
      expect(request.toJson(), {
        'jenisPajak': 6,
        'noReferensi': '35.78.010.001.902.00001',
        'tipePembayaran': 'va',
        // masa tanpa keyTagihan tidak dikirim
        'keyTagihan': ['enc-1'],
      });

      final session = result.getOrElse(() => throw 'harus Right');
      expect(session.reference, 'VA123');
      expect(session.method, PaymentMethod.vaBankJatim);
      expect(session.taxTypeId, 6);
      expect(session.referenceLabel, 'NOP');
      expect(session.referenceNumber, '35.78.010.001.902.00001');
      expect(session.taxpayerName, 'PT Sumber Air');
      expect(session.periods, const [_masaBelumLunas, _masaTanpaKey]);
      expect(session.validFor, const Duration(seconds: 900));
      expect(session.total, 100000);
      expect(session.vaNumber, '8812345678');
      expect(session.qrisPayload, isNull);
      expect(session.nmid, isNull);
      expect(session.principalTotal, 200000);
      expect(session.penaltyTotal, 0);
      expect(session.otherTotal, 0);
      expect(session.discountTotal, 0);
    });

    test('QRIS memakai tipePembayaran "qris"', () async {
      dataSource.session = PaymentSessionModel.fromJson({
        'kodeBayar': 'QR1',
        'qrValue': '000201...',
        'nmid': 'ID2021112825553',
      });

      final result = await repository.createPayment(
        taxTypeId: 7,
        referenceLabel: 'No SKPD',
        referenceNumber: 'SKPD-0001',
        taxpayerName: 'CV Iklan',
        periods: const [_masaBelumLunas],
        method: PaymentMethod.qris,
      );

      final request = dataSource.calls.single as CreatePaymentRequestModel;
      expect(request.tipePembayaran, 'qris');
      final session = result.getOrElse(() => throw 'harus Right');
      expect(session.qrisPayload, '000201...');
      expect(session.nmid, 'ID2021112825553');
      expect(session.validFor, Duration.zero);
    });

    test('tagihan sudah lunas ditolak server → ServerFailure', () async {
      dataSource.error = const ServerException(
        400,
        'Tagihan yang dipilih tidak ditemukan atau sudah lunas',
      );

      final result = await repository.createPayment(
        taxTypeId: 6,
        referenceLabel: 'NOP',
        referenceNumber: '35.78.010.001.902.00001',
        taxpayerName: 'PT Sumber Air',
        periods: const [_masaBelumLunas],
        method: PaymentMethod.qris,
      );

      expect(
        result,
        const Left<Failure, dynamic>(
          ServerFailure(
            'Tagihan yang dipilih tidak ditemukan atau sudah lunas',
          ),
        ),
      );
    });
  });

  group('getPaymentStatus', () {
    final session = PaymentSessionEntity(
      reference: 'QR1',
      method: PaymentMethod.qris,
      taxTypeId: 7,
      referenceLabel: 'No SKPD',
      referenceNumber: 'SKPD-0001',
      taxpayerName: 'CV Iklan',
      periods: const [_masaBelumLunas],
      createdAt: DateTime(2026, 10, 15, 9),
      validFor: const Duration(minutes: 15),
      total: 100000,
    );

    test('kirim metode & kode bayar, memetakan status lunas', () async {
      dataSource.status = PaymentStatusModel.fromJson({
        'isLunas': true,
        'tglBayar': '2026-10-15T09:05:00',
        'coreReference': 'CR-1',
        'jumlahBayar': 100000.2,
      });

      final result = await repository.getPaymentStatus(session);

      expect(dataSource.calls.single, 'qris|QR1');
      final status = result.getOrElse(() => throw 'harus Right');
      expect(status.isPaid, isTrue);
      expect(status.paidAt, DateTime(2026, 10, 15, 9, 5));
      expect(status.coreReference, 'CR-1');
      expect(status.amount, 100000);
    });

    test('belum lunas: field opsional null', () async {
      dataSource.status = PaymentStatusModel.fromJson({'isLunas': false});

      final result = await repository.getPaymentStatus(session);

      final status = result.getOrElse(() => throw 'harus Right');
      expect(status.isPaid, isFalse);
      expect(status.paidAt, isNull);
      expect(status.coreReference, isNull);
      expect(status.amount, isNull);
    });
  });

  group('pemetaan error ke Failure', () {
    DioException dio(DioExceptionType type) => DioException(
      requestOptions: RequestOptions(path: '/api/pembayaran/jenis-pajak'),
      type: type,
    );

    final cases = <String, (Object, Failure)>{
      'timeout': (
        dio(DioExceptionType.connectionTimeout),
        const TimeoutFailure(),
      ),
      'koneksi putus': (
        dio(DioExceptionType.connectionError),
        const NoInternetFailure(),
      ),
      'token tidak valid': (
        const UnauthorizedException(),
        const UnauthorizedFailure(),
      ),
      'tanpa internet (AppException)': (
        const NoInternetException(),
        const NoInternetFailure(),
      ),
      'error lain': (const FormatException('rusak'), const UnknownFailure()),
    };

    for (final entry in cases.entries) {
      test(entry.key, () async {
        dataSource.error = entry.value.$1;

        expect(
          await repository.getTaxTypes(),
          Left<Failure, dynamic>(entry.value.$2),
        );
        expect(
          await repository.checkNominal(1000),
          Left<Failure, dynamic>(entry.value.$2),
        );
      });
    }
  });

  group('searchObjects', () {
    test('kirim keyword & halaman, memetakan hasil ke entity', () async {
      dataSource.objects = TaxObjectSearchModel.fromJson({
        'currentPage': 1,
        'pageSize': 30,
        'totalData': 31,
        'totalPage': 2,
        'items': [
          {
            'jenisPajak': 6,
            'jenisPajakNama': 'Pajak Air Tanah',
            'nop': '35.78.051.002.908.01977',
            'nama': 'CENTRAL LAUNDRY SURABAYA',
            'alamat': 'MULYOREJO No.24',
          },
        ],
        'perJenisPajak': [
          {
            'jenisPajak': 4,
            'jenisPajakNama': 'Pajak Jasa Parkir',
            'jumlah': 40,
          },
          {'jenisPajak': 6, 'jenisPajakNama': 'Pajak Air Tanah', 'jumlah': 31},
        ],
      });

      final result = await repository.searchObjects(
        keyword: 'laundry',
        page: 1,
        pageSize: 30,
      );

      expect(dataSource.calls.single, 'laundry|1|30');
      final search = result.getOrElse(() => throw 'harus Right');
      expect(search.typeCounts.map((c) => (c.taxTypeId, c.count)), [
        (4, 40),
        (6, 31),
      ]);
      expect(search.typeCounts.first.taxTypeName, 'Pajak Jasa Parkir');
      final page = search.page;
      expect(page.totalData, 31);
      expect(page.hasMore, isTrue);
      final item = page.items.single;
      expect(item.taxTypeId, 6);
      expect(item.taxTypeName, 'Pajak Air Tanah');
      expect(item.nop, '35.78.051.002.908.01977');
      expect(item.name, 'CENTRAL LAUNDRY SURABAYA');
      expect(item.address, 'MULYOREJO No.24');
    });

    test('ServerException → ServerFailure', () async {
      dataSource.error = const ServerException(400, 'Ketik minimal 3 huruf');

      final result = await repository.searchObjects(
        keyword: 'ab',
        page: 1,
        pageSize: 30,
      );

      expect(
        result,
        const Left<Failure, dynamic>(ServerFailure('Ketik minimal 3 huruf')),
      );
    });
  });

  group('riwayat terakhir dicari', () {
    final waktu = DateTime(2026, 10, 15, 9);
    final entity = RecentReferenceEntity(
      taxTypeId: 6,
      taxTypeName: 'Pajak Air Tanah',
      referenceNumber: '35.78.051.002.908.01977',
      name: 'CENTRAL LAUNDRY SURABAYA',
      savedAt: waktu,
    );

    test('saveRecent menyimpan model lalu mengembalikan entity', () async {
      final result = await repository.saveRecent(entity);

      expect(localDataSource.items.single.noReferensi, entity.referenceNumber);
      expect(localDataSource.items.single.jenisPajak, 6);
      expect(result, [entity]);
      expect(await repository.getRecent(), [entity]);
    });

    test('clearRecent meneruskan ke datasource', () async {
      await repository.clearRecent();

      expect(localDataSource.cleared, isTrue);
    });

    test(
      'penyimpanan error: tidak melempar, riwayat dianggap kosong',
      () async {
        localDataSource.error = Exception('disk penuh');

        expect(await repository.getRecent(), isEmpty);
        expect(await repository.saveRecent(entity), isEmpty);
        await expectLater(repository.clearRecent(), completes);
      },
    );
  });
}
