import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/domain/entities/pengiriman/antrean_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/berkas_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/lacak_entity.dart';
import 'package:bapendacore/domain/repositories/pengiriman/i_pengiriman_repository.dart';
import 'package:bapendacore/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:bapendacore/presentation/features/auth/cubit/auth_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Envelope sukses / gagal bisnis `{ isSuccess, title, status, errors, data }`.
Map<String, dynamic> envelopeOk(Object? data) => {
  'isSuccess': true,
  'title': 'OK',
  'status': 200,
  'traceId': 't',
  'errors': null,
  'data': data,
};

Map<String, dynamic> envelopeGagal(String pesan, {int status = 400}) => {
  'isSuccess': false,
  'title': 'Terjadi Kesalahan',
  'status': status,
  'traceId': 't',
  'errors': [pesan],
  'data': null,
};

/// BerkasItem dari `GET daftar`.
Map<String, dynamic> berkasJson({
  String noResi = 'HMB2610000001',
  int statusId = 2,
  List<String> aksi = const ['AMBIL'],
  String namaWp = 'PT Contoh',
}) => {
  'noResi': noResi,
  'jenisKode': 'HMB',
  'jenisNama': 'Himbauan',
  'namaWp': namaWp,
  'statusId': statusId,
  'status': StatusBerkas.fromId(statusId).label,
  'alamatTujuan': 'Jl. Pemuda 1',
  'tglBatasSla': '2026-10-20T16:00:00',
  'aksi': aksi,
};

BerkasEntity berkas({
  String noResi = 'HMB2610000001',
  StatusBerkas status = StatusBerkas.ditugaskan,
  List<AksiBerkas> aksi = const [AksiBerkas.ambil],
  String namaWp = 'PT Contoh',
  bool terlambat = false,
  bool perluDikembalikan = false,
}) => BerkasEntity(
  noResi: noResi,
  jenis: JenisSurat.himbauan,
  jenisNama: 'Himbauan',
  namaWp: namaWp,
  alamatTujuan: 'Jl. Pemuda 1',
  status: status,
  statusNama: status.label,
  aksi: aksi,
  terlambat: terlambat,
  perluDikembalikan: perluDikembalikan,
);

/// Adapter Dio palsu: balas JSON tetap dan catat request terakhir.
class FakeAdapter implements HttpClientAdapter {
  final int statusCode;
  final Map<String, dynamic> json;
  RequestOptions? terakhir;

  FakeAdapter(this.json, {this.statusCode = 200});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    terakhir = options;
    return ResponseBody.fromBytes(
      utf8.encode(jsonEncode(json)),
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

typedef HasilDaftar = Either<Failure, HasilBacaEntity<List<BerkasEntity>>>;
typedef HasilDetail = Either<Failure, HasilBacaEntity<BerkasDetailEntity>>;
typedef HasilLacak = Either<Failure, LacakResultEntity>;

/// Repository palsu untuk tes cubit: tiap panggilan baca menunggu
/// Completer yang diselesaikan tes (urutan respons bisa diatur).
/// Method lain tidak dipakai cubit yang dites.
class FakePengirimanRepository implements IPengirimanRepository {
  final daftar = <Completer<HasilDaftar>>[];
  final detail = <Completer<HasilDetail>>[];
  final lacak = <({String kode, Completer<HasilLacak> c})>[];

  @override
  Future<HasilDaftar> getDaftar() {
    final c = Completer<HasilDaftar>();
    daftar.add(c);
    return c.future;
  }

  @override
  Future<HasilDetail> getDetail(String noResi) {
    final c = Completer<HasilDetail>();
    detail.add(c);
    return c.future;
  }

  /// Jawaban getRute (null = gagal / Routes API belum aktif).
  List<TitikRute>? rute;
  final ruteDiminta = <List<TitikRute>>[];

  @override
  Future<Either<Failure, List<TitikRute>>> getRute(
    List<TitikRute> titik,
  ) async {
    ruteDiminta.add(titik);
    final r = rute;
    return r == null ? const Left(ServerFailure('diblokir')) : Right(r);
  }

  @override
  Future<HasilLacak> getLacak(String kode) {
    final c = Completer<HasilLacak>();
    lacak.add((kode: kode, c: c));
    return c.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Hanya `state` AuthCubit yang dibaca cubit antrean.
class FakeAuth extends Cubit<AuthState> implements AuthCubit {
  FakeAuth([super.initialState = const AuthAuthenticated()]);

  void ubah(AuthState s) => emit(s);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeConnectivity implements Connectivity {
  final perubahan = StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      perubahan.stream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
