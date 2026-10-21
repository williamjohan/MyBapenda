import 'dart:async';

import 'package:mybapenda/core/errors/failure.dart';
import 'package:mybapenda/domain/entities/va_qris/payment_method.dart';
import 'package:mybapenda/domain/entities/va_qris/payment_nominal_check_entity.dart';
import 'package:mybapenda/domain/entities/va_qris/payment_session_entity.dart';
import 'package:mybapenda/domain/entities/va_qris/payment_status_entity.dart';
import 'package:mybapenda/domain/entities/va_qris/recent_reference_entity.dart';
import 'package:mybapenda/domain/entities/va_qris/tax_billing_entity.dart';
import 'package:mybapenda/domain/entities/va_qris/tax_object_entity.dart';
import 'package:mybapenda/domain/entities/va_qris/tax_period_entity.dart';
import 'package:mybapenda/domain/entities/va_qris/tax_type_entity.dart';
import 'package:mybapenda/domain/repositories/va_qris/i_va_qris_repository.dart';
import 'package:mybapenda/domain/usecases/va_qris/va_qris_usecase.dart';
import 'package:mybapenda/presentation/features/va_qris/cubit/va_qris_cubit.dart';
import 'package:mybapenda/presentation/features/va_qris/cubit/va_qris_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

/// Argumen `createPayment` yang diterima repository.
class _CreateCall {
  _CreateCall(this.taxTypeId, this.referenceNumber, this.periods, this.method);

  final int taxTypeId;
  final String referenceNumber;
  final List<TaxPeriodEntity> periods;
  final PaymentMethod method;
}

class _FakeRepository implements IVaQrisRepository {
  Either<Failure, List<TaxTypeEntity>> taxTypesResult = const Right(_types);
  Either<Failure, TaxBillingEntity> billingResult = Right(_billing);
  Either<Failure, PaymentNominalCheckEntity> nominalResult = const Right(
    _nominalCheck,
  );
  Either<Failure, PaymentSessionEntity> createResult = Right(_session);
  Either<Failure, PaymentStatusEntity> statusResult = const Right(_belumLunas);

  /// Diisi agar request menggantung sampai di-complete oleh test.
  Completer<void>? gate;

  final List<String> billingCalls = [];
  final List<int> nominalCalls = [];
  final List<_CreateCall> createCalls = [];
  final List<PaymentSessionEntity> statusCalls = [];

  Future<void> _wait() async {
    if (gate != null) await gate!.future;
  }

  @override
  Future<Either<Failure, List<TaxTypeEntity>>> getTaxTypes() async {
    await _wait();
    return taxTypesResult;
  }

  @override
  Future<Either<Failure, TaxBillingEntity>> getBilling({
    required int taxTypeId,
    required String referenceNumber,
  }) async {
    billingCalls.add('$taxTypeId|$referenceNumber');
    await _wait();
    return billingResult;
  }

  @override
  Future<Either<Failure, PaymentNominalCheckEntity>> checkNominal(
    int nominal,
  ) async {
    nominalCalls.add(nominal);
    await _wait();
    return nominalResult;
  }

  @override
  Future<Either<Failure, PaymentSessionEntity>> createPayment({
    required int taxTypeId,
    required String referenceLabel,
    required String referenceNumber,
    required String taxpayerName,
    required List<TaxPeriodEntity> periods,
    required PaymentMethod method,
  }) async {
    createCalls.add(_CreateCall(taxTypeId, referenceNumber, periods, method));
    await _wait();
    return createResult;
  }

  @override
  Future<Either<Failure, PaymentStatusEntity>> getPaymentStatus(
    PaymentSessionEntity session,
  ) async {
    statusCalls.add(session);
    await _wait();
    return statusResult;
  }

  // Riwayat "Terakhir dicari" (di memori)
  List<RecentReferenceEntity> recent = [];
  final List<RecentReferenceEntity> saved = [];
  bool cleared = false;

  @override
  Future<List<RecentReferenceEntity>> getRecent() async => recent;

  @override
  Future<List<RecentReferenceEntity>> saveRecent(
    RecentReferenceEntity item,
  ) async {
    saved.add(item);
    recent = [item, ...recent];
    return recent;
  }

  @override
  Future<void> clearRecent() async {
    cleared = true;
    recent = [];
  }

  @override
  Future<Either<Failure, TaxObjectSearchResultEntity>> searchObjects({
    required String keyword,
    required int page,
    required int pageSize,
  }) => throw UnimplementedError();
}

const _airTanah = TaxTypeEntity(
  id: 6,
  name: 'Pajak Air Tanah',
  referenceLabel: 'NOP',
  hint: 'Contoh: 35.78.010.001.902.00001',
  digitsOnly: true,
  mask: '##.##.###.###.###.#####',
);

const _reklame = TaxTypeEntity(
  id: 7,
  name: 'Pajak Reklame',
  referenceLabel: 'No SKPD',
  hint: 'Masukkan No SKPD',
  digitsOnly: false,
);

const _types = [_airTanah, _reklame];

const _masa1 = TaxPeriodEntity(
  key: 'k1',
  year: 2026,
  month: 8,
  label: 'Agustus 2026',
  principal: 100000,
  penalty: 2000,
  total: 102000,
);

const _masa2 = TaxPeriodEntity(
  key: 'k2',
  year: 2026,
  month: 9,
  label: 'September 2026',
  principal: 100000,
  other: 5000,
  otherLabel: 'Jaminan Bongkar',
  discount: 1000,
  total: 104000,
);

const _masa3 = TaxPeriodEntity(
  key: 'k3',
  year: 2026,
  month: 10,
  label: 'Oktober 2026',
  principal: 100000,
  total: 100000,
);

const _billing = TaxBillingEntity(
  taxTypeId: 6,
  taxType: 'Pajak Air Tanah',
  referenceLabel: 'NOP',
  referenceNumber: '35.78.010.001.902.00001',
  npwpd: 'P100',
  taxpayerName: 'PT Sumber Air',
  taxpayerAddress: 'Jl. Pemuda 1',
  objectName: 'Sumur Bor',
  address: 'Jl. Pemuda 1',
  unpaidPeriods: [_masa1, _masa2, _masa3],
  paidPeriods: [],
);

const _billingTanpaObjek = TaxBillingEntity(
  taxTypeId: 6,
  taxType: 'Pajak Air Tanah',
  referenceLabel: 'NOP',
  referenceNumber: '35.78.010.001.902.00001',
  npwpd: 'P100',
  taxpayerName: 'PT Sumber Air',
  taxpayerAddress: 'Jl. Pemuda 1',
  objectName: ' ',
  address: 'Jl. Pemuda 1',
  unpaidPeriods: [_masa1],
  paidPeriods: [],
);

final _session = PaymentSessionEntity(
  reference: 'QR001',
  method: PaymentMethod.qris,
  taxTypeId: 6,
  referenceLabel: 'NOP',
  referenceNumber: '35.78.010.001.902.00001',
  taxpayerName: 'PT Sumber Air',
  periods: const [_masa1],
  createdAt: DateTime(2026, 10, 15, 9),
  validFor: const Duration(minutes: 15),
  total: 102000,
  qrisPayload: '000201...',
);

final _sessionBaru = PaymentSessionEntity(
  reference: 'QR002',
  method: PaymentMethod.qris,
  taxTypeId: 6,
  referenceLabel: 'NOP',
  referenceNumber: '35.78.010.001.902.00001',
  taxpayerName: 'PT Sumber Air',
  periods: const [_masa1],
  createdAt: DateTime(2026, 10, 15, 9, 20),
  validFor: const Duration(minutes: 15),
  total: 102000,
  qrisPayload: '000201...',
);

const _nominalCheck = PaymentNominalCheckEntity(
  vaAllowed: true,
  vaMessage: '',
  qrisAllowed: false,
  qrisMessage: 'Nominal melebihi batas QRIS',
);

const _belumLunas = PaymentStatusEntity(isPaid: false);
const _lunas = PaymentStatusEntity(isPaid: true, coreReference: 'CR1');

const _poll = Duration(seconds: 5);

void main() {
  late _FakeRepository repository;
  late VaQrisCubit cubit;

  setUp(() {
    repository = _FakeRepository();
    cubit = VaQrisCubit(VaQrisUseCase(repository));
  });

  tearDown(() => cubit.close());

  /// Rekam semua state yang di-emit sejak dipanggil.
  List<VaQrisState> record() {
    final states = <VaQrisState>[];
    cubit.stream.listen(states.add);
    return states;
  }

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  group('init', () {
    test('sukses: isi daftar jenis pajak & pilih yang pertama', () async {
      cubit.emit(cubit.state.copyWith(errorMessage: 'lama'));

      await cubit.init();

      expect(cubit.state.status, VaQrisStatus.initial);
      expect(cubit.state.taxTypes, _types);
      expect(cubit.state.selectedTaxType, _airTanah);
      expect(cubit.state.errorMessage, isNull);
    });

    test('daftar kosong: tidak ada jenis pajak terpilih', () async {
      repository.taxTypesResult = const Right([]);

      await cubit.init();

      expect(cubit.state.taxTypes, isEmpty);
      expect(cubit.state.selectedTaxType, isNull);
    });

    test('gagal: status failure dengan pesan dari Failure', () async {
      repository.taxTypesResult = const Left(NoInternetFailure());

      await cubit.init();

      expect(cubit.state.status, VaQrisStatus.failure);
      expect(cubit.state.errorMessage, const NoInternetFailure().message);
    });

    test('Cubit ditutup sebelum response datang: tidak emit', () async {
      repository.gate = Completer<void>();
      final future = cubit.init();
      await cubit.close();
      repository.gate!.complete();

      await expectLater(future, completes);
      expect(cubit.state, const VaQrisState());
    });
  });

  group('selectTaxType & clearError', () {
    test('memilih jenis pajak me-reset status & pesan error', () {
      cubit.emit(
        cubit.state.copyWith(status: VaQrisStatus.failure, errorMessage: 'x'),
      );

      cubit.selectTaxType(_reklame);

      expect(cubit.state.selectedTaxType, _reklame);
      expect(cubit.state.status, VaQrisStatus.initial);
      expect(cubit.state.errorMessage, isNull);
    });

    test('clearError menghapus pesan error', () {
      cubit.emit(cubit.state.copyWith(errorMessage: 'x'));

      cubit.clearError();

      expect(cubit.state.errorMessage, isNull);
    });

    test('clearError tanpa error tidak emit state baru', () async {
      final states = record();

      cubit.clearError();
      await flush();

      expect(states, isEmpty);
    });
  });

  group('searchBilling', () {
    test('tanpa jenis pajak terpilih: tidak memanggil API', () async {
      await cubit.searchBilling('123');

      expect(repository.billingCalls, isEmpty);
      expect(cubit.state.status, VaQrisStatus.initial);
    });

    test('sukses: searching → loaded dengan tagihan', () async {
      cubit.selectTaxType(_airTanah);
      final states = expectLater(
        cubit.stream.map((s) => s.status),
        emitsInOrder([VaQrisStatus.searching, VaQrisStatus.loaded]),
      );

      await cubit.searchBilling('35.78.010.001.902.00001');
      await states;

      expect(repository.billingCalls.single, '6|35.78.010.001.902.00001');
      expect(cubit.state.billing, _billing);
    });

    test('gagal: status failure dengan pesan server', () async {
      cubit.selectTaxType(_reklame);
      repository.billingResult = const Left(
        ServerFailure('No SKPD tidak ditemukan'),
      );

      await cubit.searchBilling('SKPD-0001');

      expect(cubit.state.status, VaQrisStatus.failure);
      expect(cubit.state.errorMessage, 'No SKPD tidak ditemukan');
      expect(cubit.state.billing, isNull);
    });

    test(
      'tombol ditekan dua kali saat masih mencari: API dipanggil sekali',
      () async {
        cubit.selectTaxType(_reklame);
        repository.gate = Completer<void>();

        final first = cubit.searchBilling('SKPD-0001');
        await cubit.searchBilling('SKPD-0001');
        repository.gate!.complete();
        await first;

        expect(repository.billingCalls, hasLength(1));
        expect(cubit.state.status, VaQrisStatus.loaded);
      },
    );

    test('Cubit ditutup sebelum response datang: tidak emit', () async {
      cubit.selectTaxType(_reklame);
      repository.gate = Completer<void>();
      final future = cubit.searchBilling('SKPD-0001');
      await cubit.close();
      repository.gate!.complete();

      await expectLater(future, completes);
      expect(cubit.state.status, VaQrisStatus.searching);
    });
  });

  group('loadBilling & togglePeriod', () {
    test('loadBilling memilih masa terlama secara default', () {
      cubit.loadBilling(_billing);

      expect(cubit.state.status, VaQrisStatus.loaded);
      expect(cubit.state.billing, _billing);
      expect(cubit.state.selectedCount, 1);
      expect(cubit.state.selectedPeriods, [_masa1]);
    });

    test('loadBilling tanpa tunggakan: tidak ada masa terpilih', () {
      const lunasSemua = TaxBillingEntity(
        taxTypeId: 7,
        taxType: 'Pajak Reklame',
        referenceLabel: 'No SKPD',
        referenceNumber: 'SKPD-0001',
        npwpd: 'P200',
        taxpayerName: 'CV Iklan',
        taxpayerAddress: 'Jl. Darmo 2',
        objectName: 'Billboard',
        address: 'Jl. Darmo 2',
        unpaidPeriods: [],
        paidPeriods: [_masa1],
      );

      cubit.loadBilling(lunasSemua);

      expect(cubit.state.selectedCount, 0);
      expect(cubit.state.selectedPeriods, isEmpty);
    });

    test('centang masa mana saja, tidak harus berurutan', () {
      cubit.loadBilling(_billing);

      // Batal masa terlama, lalu centang hanya masa ke-3
      cubit.togglePeriod(_masa1);
      cubit.togglePeriod(_masa3);
      expect(cubit.state.selectedPeriods, [_masa3]);
      expect(cubit.state.selectedCount, 1);

      // Tambah masa ke-1: hasil tetap urut terlama (urutan dari API)
      cubit.togglePeriod(_masa1);
      expect(cubit.state.selectedPeriods, [_masa1, _masa3]);
    });

    test('batal centang satu masa tidak mengubah masa lain', () {
      cubit.loadBilling(_billing);
      cubit.togglePeriod(_masa2);
      cubit.togglePeriod(_masa3);

      cubit.togglePeriod(_masa2);
      expect(cubit.state.selectedPeriods, [_masa1, _masa3]);

      cubit.togglePeriod(_masa1);
      cubit.togglePeriod(_masa3);
      expect(cubit.state.selectedPeriods, isEmpty);
    });

    test('toggleAllPeriods: pilih semua lalu batal semua', () {
      cubit.loadBilling(_billing);
      expect(cubit.state.allPeriodsSelected, isFalse);

      cubit.toggleAllPeriods();
      expect(cubit.state.selectedPeriods, [_masa1, _masa2, _masa3]);
      expect(cubit.state.allPeriodsSelected, isTrue);

      cubit.toggleAllPeriods();
      expect(cubit.state.selectedPeriods, isEmpty);
      expect(cubit.state.allPeriodsSelected, isFalse);
    });

    test('toggleAllPeriods tanpa tagihan: tidak memilih apa pun', () {
      cubit.toggleAllPeriods();

      expect(cubit.state.selectedKeys, isEmpty);
      expect(cubit.state.allPeriodsSelected, isFalse);
    });

    test('loadBilling tagihan baru mengganti pilihan lama', () {
      cubit.loadBilling(_billing);
      cubit.toggleAllPeriods();

      cubit.loadBilling(_billing.copyWithUnpaid(const [_masa2, _masa3]));

      expect(cubit.state.selectedPeriods, [_masa2]);
    });
  });

  group('rincian total di state', () {
    test(
      'menjumlahkan pokok, denda, lainnya, potongan & total masa terpilih',
      () {
        cubit.loadBilling(_billing);
        cubit.togglePeriod(_masa2);

        final s = cubit.state;
        expect(s.selectedTotal, 206000);
        expect(s.selectedPrincipal, 200000);
        expect(s.selectedPenalty, 2000);
        expect(s.selectedOther, 5000);
        expect(s.selectedDiscount, 1000);
        expect(s.selectedOtherLabel, isNull);
      },
    );

    test('label lainnya diambil dari masa terpilih pertama', () {
      cubit.loadBilling(_billing.copyWithUnpaid(const [_masa2, _masa3]));

      expect(cubit.state.selectedOtherLabel, 'Jaminan Bongkar');
    });

    test('tanpa tagihan semua total 0 dan label null', () {
      const s = VaQrisState();

      expect(s.selectedPeriods, isEmpty);
      expect(s.selectedTotal, 0);
      expect(s.selectedOtherLabel, isNull);
      expect(s.isExpired, isFalse);
    });

    test('isExpired mengikuti sessionStatus', () {
      const s = VaQrisState(sessionStatus: PaymentSessionStatus.expired);

      expect(s.isExpired, isTrue);
    });
  });

  group('checkNominal', () {
    test('total 0: tidak memanggil API dan mengembalikan null', () async {
      cubit.loadBilling(_billing);
      cubit.togglePeriod(_masa1);

      expect(await cubit.checkNominal(), isNull);
      expect(repository.nominalCalls, isEmpty);
    });

    test(
      'sukses: kirim total masa terpilih dan kembalikan hasil cek',
      () async {
        cubit.loadBilling(_billing);
        cubit.togglePeriod(_masa2);
        final confirming = expectLater(
          cubit.stream.map((s) => s.confirming),
          emitsInOrder([true, false]),
        );

        final result = await cubit.checkNominal();
        await confirming;

        expect(repository.nominalCalls.single, 206000);
        expect(result, _nominalCheck);
        expect(result!.isAllowed(PaymentMethod.vaBankJatim), isTrue);
        expect(result.isAllowed(PaymentMethod.qris), isFalse);
        expect(
          result.messageFor(PaymentMethod.qris),
          'Nominal melebihi batas QRIS',
        );
        expect(result.messageFor(PaymentMethod.vaBankJatim), '');
      },
    );

    test('gagal: kembalikan null dan confirming kembali false', () async {
      cubit.loadBilling(_billing);
      repository.nominalResult = const Left(TimeoutFailure());

      expect(await cubit.checkNominal(), isNull);
      expect(cubit.state.confirming, isFalse);
      expect(cubit.state.errorMessage, isNull);
    });

    test('sedang konfirmasi: tidak memanggil API lagi', () async {
      cubit.loadBilling(_billing);
      cubit.emit(cubit.state.copyWith(confirming: true));

      expect(await cubit.checkNominal(), isNull);
      expect(repository.nominalCalls, isEmpty);
    });

    test('Cubit ditutup sebelum response datang: kembalikan null', () async {
      cubit.loadBilling(_billing);
      repository.gate = Completer<void>();
      final future = cubit.checkNominal();
      await cubit.close();
      repository.gate!.complete();

      expect(await future, isNull);
    });
  });

  group('confirmPayment', () {
    test('tanpa tagihan: tidak memanggil API', () async {
      await cubit.confirmPayment(PaymentMethod.qris);

      expect(repository.createCalls, isEmpty);
    });

    test('tanpa masa terpilih: tidak memanggil API', () async {
      cubit.loadBilling(_billing);
      cubit.togglePeriod(_masa1);

      await cubit.confirmPayment(PaymentMethod.qris);

      expect(repository.createCalls, isEmpty);
    });

    test('sedang konfirmasi: tidak memanggil API lagi', () async {
      cubit.loadBilling(_billing);
      cubit.emit(cubit.state.copyWith(confirming: true));

      await cubit.confirmPayment(PaymentMethod.qris);

      expect(repository.createCalls, isEmpty);
    });

    test('sukses: kirim masa terpilih & metode, simpan sesi bayar', () async {
      cubit.loadBilling(_billing);
      cubit.togglePeriod(_masa3);
      repository.createResult = Right(_session);

      await cubit.confirmPayment(PaymentMethod.vaBankJatim);

      final call = repository.createCalls.single;
      expect(call.taxTypeId, 6);
      expect(call.referenceNumber, '35.78.010.001.902.00001');
      // Tidak berurutan (masa ke-1 & ke-3) tetap dikirim apa adanya
      expect(call.periods, [_masa1, _masa3]);
      expect(call.method, PaymentMethod.vaBankJatim);
      expect(cubit.state.session, _session);
      expect(cubit.state.confirming, isFalse);
      expect(cubit.state.errorMessage, isNull);
    });

    test('gagal: tampilkan pesan dan sesi tetap kosong', () async {
      cubit.loadBilling(_billing);
      repository.createResult = const Left(
        ServerFailure('Tagihan yang dipilih tidak ditemukan atau sudah lunas'),
      );

      await cubit.confirmPayment(PaymentMethod.qris);

      expect(cubit.state.session, isNull);
      expect(cubit.state.confirming, isFalse);
      expect(
        cubit.state.errorMessage,
        'Tagihan yang dipilih tidak ditemukan atau sudah lunas',
      );
    });

    test('Cubit ditutup sebelum response datang: tidak emit', () async {
      cubit.loadBilling(_billing);
      repository.gate = Completer<void>();
      final future = cubit.confirmPayment(PaymentMethod.qris);
      await cubit.close();
      repository.gate!.complete();

      await expectLater(future, completes);
      expect(cubit.state.session, isNull);
    });
  });

  // testWidgets dipakai karena berjalan di zona FakeAsync: Timer.periodic
  // polling 5 detik bisa dimajukan dengan tester.pump tanpa menunggu sungguhan.
  group('polling status pembayaran', () {
    testWidgets('startSession: pending lalu cek status tiap 5 detik', (
      tester,
    ) async {
      final cubit = VaQrisCubit(VaQrisUseCase(repository));

      cubit.startSession(_session);
      expect(cubit.state.session, _session);
      expect(cubit.state.sessionStatus, PaymentSessionStatus.pending);
      expect(repository.statusCalls, isEmpty);

      await tester.pump(_poll);
      expect(repository.statusCalls.single, _session);
      expect(cubit.state.sessionStatus, PaymentSessionStatus.pending);

      await tester.pump(_poll);
      expect(repository.statusCalls, hasLength(2));

      await cubit.close();
    });

    testWidgets('lunas: status paid dan polling berhenti', (tester) async {
      final cubit = VaQrisCubit(VaQrisUseCase(repository));
      repository.statusResult = const Right(_lunas);

      cubit.startSession(_session);
      await tester.pump(_poll);

      expect(cubit.state.sessionStatus, PaymentSessionStatus.paid);

      await tester.pump(_poll * 3);
      expect(repository.statusCalls, hasLength(1));

      await cubit.close();
    });

    testWidgets('cek status gagal (jaringan): polling tetap berjalan', (
      tester,
    ) async {
      final cubit = VaQrisCubit(VaQrisUseCase(repository));
      repository.statusResult = const Left(NoInternetFailure());

      cubit.startSession(_session);
      await tester.pump(_poll);
      expect(cubit.state.sessionStatus, PaymentSessionStatus.pending);

      repository.statusResult = const Right(_lunas);
      await tester.pump(_poll);

      expect(repository.statusCalls, hasLength(2));
      expect(cubit.state.sessionStatus, PaymentSessionStatus.paid);

      await cubit.close();
    });

    testWidgets('request status lambat: tick berikutnya dilewati', (
      tester,
    ) async {
      final cubit = VaQrisCubit(VaQrisUseCase(repository));
      repository.gate = Completer<void>();

      cubit.startSession(_session);
      await tester.pump(_poll);
      await tester.pump(_poll);
      expect(repository.statusCalls, hasLength(1));

      repository.gate!.complete();
      await tester.pump();
      repository.gate = null;
      await tester.pump(_poll);
      expect(repository.statusCalls, hasLength(2));

      await cubit.close();
    });

    testWidgets('response status untuk sesi lama diabaikan', (tester) async {
      final cubit = VaQrisCubit(VaQrisUseCase(repository));
      repository.gate = Completer<void>();
      repository.statusResult = const Right(_lunas);

      cubit.startSession(_session);
      await tester.pump(_poll);
      // Sesi berganti saat request status masih berjalan
      cubit.emit(cubit.state.copyWith(session: _sessionBaru));
      repository.gate!.complete();
      await tester.pump();

      expect(cubit.state.sessionStatus, PaymentSessionStatus.pending);

      await cubit.close();
    });

    testWidgets('markExpired: status expired dan polling berhenti', (
      tester,
    ) async {
      final cubit = VaQrisCubit(VaQrisUseCase(repository));

      cubit.startSession(_session);
      cubit.markExpired();

      expect(cubit.state.isExpired, isTrue);
      await tester.pump(_poll * 3);
      expect(repository.statusCalls, isEmpty);

      await cubit.close();
    });

    testWidgets('markExpired setelah lunas: status tetap paid', (tester) async {
      final cubit = VaQrisCubit(VaQrisUseCase(repository));
      repository.statusResult = const Right(_lunas);

      cubit.startSession(_session);
      await tester.pump(_poll);
      cubit.markExpired();

      expect(cubit.state.sessionStatus, PaymentSessionStatus.paid);

      await cubit.close();
    });

    testWidgets('close: timer polling dibatalkan', (tester) async {
      final cubit = VaQrisCubit(VaQrisUseCase(repository));

      cubit.startSession(_session);
      await cubit.close();
      await tester.pump(_poll * 3);

      expect(repository.statusCalls, isEmpty);
    });
  });

  group('regenerateSession', () {
    test('tanpa sesi: tidak memanggil API', () async {
      await cubit.regenerateSession();

      expect(repository.createCalls, isEmpty);
    });

    test('sedang konfirmasi: tidak memanggil API', () async {
      cubit.emit(cubit.state.copyWith(session: _session, confirming: true));

      await cubit.regenerateSession();

      expect(repository.createCalls, isEmpty);
    });

    testWidgets('sukses: pakai konteks sesi lama, status pending & polling', (
      tester,
    ) async {
      final cubit = VaQrisCubit(VaQrisUseCase(repository));
      cubit.startSession(_session);
      cubit.markExpired();
      repository.createResult = Right(_sessionBaru);

      await cubit.regenerateSession();

      final call = repository.createCalls.single;
      expect(call.taxTypeId, _session.taxTypeId);
      expect(call.referenceNumber, _session.referenceNumber);
      expect(call.periods, _session.periods);
      expect(call.method, _session.method);
      expect(cubit.state.session, _sessionBaru);
      expect(cubit.state.sessionStatus, PaymentSessionStatus.pending);

      await tester.pump(_poll);
      expect(repository.statusCalls.single, _sessionBaru);

      await cubit.close();
    });

    test('gagal: tampilkan pesan, sesi & status expired tetap', () async {
      cubit.startSession(_session);
      cubit.markExpired();
      repository.createResult = const Left(ServerFailure('Gagal membuat VA'));

      await cubit.regenerateSession();

      expect(cubit.state.session, _session);
      expect(cubit.state.isExpired, isTrue);
      expect(cubit.state.errorMessage, 'Gagal membuat VA');
    });
  });

  group('riwayat terakhir dicari', () {
    final lama = RecentReferenceEntity(
      taxTypeId: 6,
      taxTypeName: 'Pajak Air Tanah',
      referenceNumber: '35.78.010.001.902.00009',
      name: 'Sumur Lama',
      savedAt: DateTime(2026, 10, 1),
    );

    test('init memuat riwayat', () async {
      repository.recent = [lama];

      await cubit.init();

      expect(cubit.state.recent, [lama]);
    });

    test('tagihan ditemukan: disimpan ke riwayat (nama objek)', () async {
      await cubit.init();
      cubit.selectTaxType(_airTanah);

      await cubit.searchBilling('35.78.010.001.902.00001');

      final saved = repository.saved.single;
      expect(saved.taxTypeId, 6);
      expect(saved.taxTypeName, 'Pajak Air Tanah');
      expect(saved.referenceNumber, _billing.referenceNumber);
      expect(saved.name, 'Sumur Bor');
      expect(cubit.state.recent.first, saved);
    });

    test('nama objek kosong: pakai nama WP', () async {
      repository.billingResult = Right(_billingTanpaObjek);
      cubit.selectTaxType(_airTanah);

      await cubit.searchBilling('35.78.010.001.902.00001');

      expect(repository.saved.single.name, 'PT Sumber Air');
    });

    test('Reklame (No SKPD) tidak disimpan ke riwayat', () async {
      cubit.selectTaxType(_reklame);

      await cubit.searchBilling('SKPD-0001');

      expect(cubit.state.status, VaQrisStatus.loaded);
      expect(repository.saved, isEmpty);
    });

    test('tagihan gagal dicari: tidak disimpan', () async {
      repository.billingResult = const Left(ServerFailure('NOP tidak ada'));
      cubit.selectTaxType(_airTanah);

      await cubit.searchBilling('35.78.010.001.902.00009');

      expect(repository.saved, isEmpty);
    });

    test('clearRecent mengosongkan riwayat', () async {
      repository.recent = [lama];
      await cubit.init();

      await cubit.clearRecent();

      expect(cubit.state.recent, isEmpty);
      expect(repository.cleared, isTrue);
    });
  });

  group('pickReference (Cari objek pajak / riwayat)', () {
    test(
      'memilih jenis pajak objek lalu langsung cari tagihan, NOP tanpa titik',
      () async {
        await cubit.init();
        cubit.selectTaxType(_reklame);

        await cubit.pickReference(
          taxTypeId: 6,
          referenceNumber: '35.78.010.001.902.00001',
        );

        expect(cubit.state.selectedTaxType, _airTanah);
        expect(repository.billingCalls.single, '6|357801000190200001');
        expect(cubit.state.status, VaQrisStatus.loaded);
      },
    );

    test('No SKPD (bukan angka) dikirim apa adanya', () async {
      await cubit.init();

      await cubit.pickReference(taxTypeId: 7, referenceNumber: ' SKPD-0001 ');

      expect(cubit.state.selectedTaxType, _reklame);
      expect(repository.billingCalls.single, '7|SKPD-0001');
    });

    test(
      'jenis pajak tidak ada di daftar: gagal tanpa memanggil API',
      () async {
        await cubit.init();

        await cubit.pickReference(taxTypeId: 99, referenceNumber: '123');

        expect(cubit.state.status, VaQrisStatus.failure);
        expect(
          cubit.state.errorMessage,
          'Jenis pajak objek ini tidak tersedia untuk pembayaran.',
        );
        expect(cubit.state.selectedTaxType, _airTanah);
        expect(repository.billingCalls, isEmpty);
      },
    );

    test('sedang mencari: pilihan diabaikan', () async {
      await cubit.init();
      repository.gate = Completer<void>();
      final first = cubit.searchBilling('35.78.010.001.902.00001');

      await cubit.pickReference(taxTypeId: 7, referenceNumber: 'SKPD-0001');
      repository.gate!.complete();
      await first;

      expect(repository.billingCalls, hasLength(1));
      expect(cubit.state.selectedTaxType, _airTanah);
    });
  });
}

extension on TaxBillingEntity {
  TaxBillingEntity copyWithUnpaid(List<TaxPeriodEntity> unpaid) =>
      TaxBillingEntity(
        taxTypeId: taxTypeId,
        taxType: taxType,
        referenceLabel: referenceLabel,
        referenceNumber: referenceNumber,
        npwpd: npwpd,
        taxpayerName: taxpayerName,
        taxpayerAddress: taxpayerAddress,
        objectName: objectName,
        address: address,
        unpaidPeriods: unpaid,
        paidPeriods: paidPeriods,
      );
}
