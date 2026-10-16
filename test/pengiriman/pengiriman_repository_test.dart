// ignore_for_file: depend_on_referenced_packages
import 'dart:convert';
import 'dart:io';

import 'package:bapendacore/core/errors/exception.dart';
import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/core/network/api_endpoints.dart';
import 'package:bapendacore/core/storage/app_secure_storage.dart';
import 'package:bapendacore/core/storage/pengiriman_cache_storage.dart';
import 'package:bapendacore/core/storage/pengiriman_queue_storage.dart';
import 'package:bapendacore/data/datasources/pengiriman/pengiriman_remote_datasource.dart';
import 'package:bapendacore/data/datasources/pengiriman/rute_remote_datasource.dart';
import 'package:bapendacore/data/models/pengiriman/rute_model.dart';
import 'package:bapendacore/domain/entities/pengiriman/lacak_entity.dart';
import 'package:bapendacore/data/models/pengiriman/berkas_model.dart';
import 'package:bapendacore/data/models/pengiriman/lacak_model.dart';
import 'package:bapendacore/data/models/pengiriman/master_pengiriman_model.dart';
import 'package:bapendacore/domain/entities/pengiriman/master_pengiriman_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/pengiriman_payload_entity.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:bapendacore/data/repositories/pengiriman/pengiriman_repository_impl.dart';
import 'package:bapendacore/domain/entities/pengiriman/antrean_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/berkas_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/pengiriman_fakes.dart';
import 'helpers/platform_fakes.dart';

const _nip = '199001012020011001';

class _FakeSecureStorage extends AppSecureStorage {
  _FakeSecureStorage() : super(const FlutterSecureStorage());

  @override
  Future<String?> getCurrentNip() async => _nip;
}

/// Datasource palsu: [daftar] dilempar bila berupa Exception; [kirim]
/// diproses berurutan per POST (Exception dilempar, list jadi hasil).
class _FakeDataSource implements IPengirimanRemoteDataSource {
  Object daftar = <BerkasModel>[];

  /// BerkasDetailModel atau Exception.
  Object? detail;
  Object master = MasterPengirimanModel.fromJson(const {});
  Object? lacak;
  FormData? formAmbil;
  final kirim = <Object>[];
  final terkirim = <String>[];

  static T _atau<T>(Object? v) {
    if (v is Exception) throw v;
    return v as T;
  }

  @override
  Future<MasterPengirimanModel> getMaster() async => _atau(master);

  @override
  Future<BerkasDetailModel> getDetail(String noResi) async => _atau(detail);

  @override
  Future<LacakResultModel> getLacak(String kode) async => _atau(lacak);

  @override
  Future<List<HasilCheckinModel>> postAmbil(FormData form) async {
    formAmbil = form;
    return [
      HasilCheckinModel.fromJson(const {'noResi': 'A', 'statusId': 3}),
    ];
  }

  @override
  Future<List<BerkasModel>> getDaftar() async {
    final d = daftar;
    if (d is Exception) throw d;
    return d as List<BerkasModel>;
  }

  @override
  Future<List<HasilCheckinModel>> postForm(
    String endpoint,
    FormData form,
  ) async {
    final hasil = kirim.removeAt(0);
    if (hasil is Exception) throw hasil;
    terkirim.add(endpoint);
    return hasil as List<HasilCheckinModel>;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AntreanRecord _rec(String uuid, String jenis, String noResi) => AntreanRecord(
  checkinUuid: uuid,
  jenis: jenis,
  endpoint: '/api/pengiriman/$jenis',
  noResi: [noResi],
  fields: [
    ['noResi', noResi],
    ['checkinUuid', uuid],
  ],
  files: const {},
  tglDibuat: DateTime(2026, 10, 15, 9),
);

Future<
  ({
    PengirimanRepositoryImpl repo,
    _FakeDataSource ds,
    PengirimanQueueStorage queue,
  })
>
_siapkan({List<AntreanRecord> antrean = const []}) async {
  SharedPreferences.setMockInitialValues({
    if (antrean.isNotEmpty)
      'pengiriman_antrean_$_nip': jsonEncode([
        for (final r in antrean) r.toJson(),
      ]),
  });
  final prefs = await SharedPreferences.getInstance();
  final ds = _FakeDataSource();
  final queue = PengirimanQueueStorage(prefs);
  final repo = PengirimanRepositoryImpl(
    ds,
    queue,
    PengirimanCacheStorage(prefs),
    _FakeSecureStorage(),
    _rute,
  );
  return (repo: repo, ds: ds, queue: queue);
}

/// Routes API palsu: [hasil] = RuteModel atau Exception.
class _FakeRuteDataSource implements IRuteRemoteDataSource {
  Object hasil = const RuteModel(encodedPolyline: '_p~iF~ps|U_ulLnnqC');
  List<TitikRute>? diminta;

  @override
  Future<RuteModel> hitungRute(List<TitikRute> titik) async {
    diminta = titik;
    final h = hasil;
    if (h is Exception) throw h;
    return h as RuteModel;
  }
}

final _rute = _FakeRuteDataSource();

BerkasModel _model(String noResi, {int statusId = 4, List<String>? aksi}) =>
    BerkasModel.fromJson(
      berkasJson(
        noResi: noResi,
        statusId: statusId,
        aksi: aksi ?? const ['PERJALANAN', 'TIBA', 'GAGAL'],
      ),
    );

void main() {
  // Hapus folder foto antrean memanggil path_provider (tidak ada di tes;
  // galatnya ditangkap storage).
  TestWidgetsFlutterBinding.ensureInitialized();

  group('getDaftar & cache offline', () {
    test('online: data server, tanpa tanda cache', () async {
      final s = await _siapkan();
      s.ds.daftar = [_model('A')];

      final r = await s.repo.getDaftar();

      final hasil = r.getOrElse(() => throw 'gagal');
      expect(hasil.data.single.noResi, 'A');
      expect(hasil.dariCache, isFalse);
    });

    test('offline: pakai salinan terakhir + tanggal cache', () async {
      final s = await _siapkan();
      s.ds.daftar = [_model('A'), _model('B')];
      await s.repo.getDaftar();

      s.ds.daftar = const NoInternetException();
      final r = await s.repo.getDaftar();

      final hasil = r.getOrElse(() => throw 'gagal');
      expect(hasil.data.map((b) => b.noResi), ['A', 'B']);
      expect(hasil.dariCache, isTrue);
    });

    test('timeout tanpa cache → TimeoutFailure', () async {
      final s = await _siapkan();
      s.ds.daftar = const TimeoutException();

      final r = await s.repo.getDaftar();

      expect(r.fold((f) => f, (_) => null), isA<TimeoutFailure>());
    });

    test('ditolak server → tetap gagal walau ada cache', () async {
      final s = await _siapkan();
      s.ds.daftar = [_model('A')];
      await s.repo.getDaftar();

      s.ds.daftar = const ServerException(403, 'Akses ditolak.');
      final r = await s.repo.getDaftar();

      expect(r.fold((f) => f.message, (_) => null), 'Akses ditolak.');
    });

    test('aksi di antrean ditampilkan sementara (overlay)', () async {
      final s = await _siapkan(antrean: [_rec('u1', 'tiba', 'A')]);
      s.ds.daftar = [_model('A'), _model('B')];

      final r = await s.repo.getDaftar();

      final list = r.getOrElse(() => throw 'gagal').data;
      expect(list[0].status, StatusBerkas.tiba);
      expect(list[0].aksi, [AksiBerkas.serah, AksiBerkas.gagal]);
      expect(list[0].antreanTertunda, 1);
      expect(list[1].status, StatusBerkas.dalamPerjalanan);
    });
  });

  group('sinkronkan antrean', () {
    test('FIFO: semua terkirim berurutan lalu antrean kosong', () async {
      final s = await _siapkan(
        antrean: [_rec('u1', 'tiba', 'A'), _rec('u2', 'serah', 'A')],
      );
      s.ds.kirim.addAll([<HasilCheckinModel>[], <HasilCheckinModel>[]]);

      await s.repo.sinkronkan();

      expect(s.ds.terkirim, [
        ApiEndpoints.pengirimanTiba,
        ApiEndpoints.pengirimanSerah,
      ]);
      expect(s.queue.menunggu(_nip), isEmpty);
    });

    test('galat sementara: berhenti, urutan & jumlah coba tersimpan', () async {
      final s = await _siapkan(
        antrean: [_rec('u1', 'tiba', 'A'), _rec('u2', 'serah', 'A')],
      );
      s.ds.kirim.add(const TimeoutException());

      await s.repo.sinkronkan();

      final sisa = s.queue.menunggu(_nip);
      expect(sisa.map((r) => r.checkinUuid), ['u1', 'u2']);
      expect(sisa.first.jmlCoba, 1);
      expect(sisa.first.pesanError, isNotNull);
      expect(s.ds.terkirim, isEmpty);
    });

    test('ditolak server: pindah ke gagal, lanjut ke berikutnya', () async {
      final s = await _siapkan(
        antrean: [_rec('u1', 'tiba', 'A'), _rec('u2', 'tiba', 'B')],
      );
      s.ds.kirim.addAll([
        const ServerException(400, 'Berkas sudah diterima.'),
        <HasilCheckinModel>[],
      ]);

      await s.repo.sinkronkan();

      expect(s.queue.menunggu(_nip), isEmpty);
      final gagal = s.queue.gagal(_nip).single;
      expect(gagal.checkinUuid, 'u1');
      expect(gagal.pesanError, 'Berkas sudah diterima.');
      expect(s.ds.terkirim, [ApiEndpoints.pengirimanTiba]);
    });

    test('diterima tapi diabaikan server: masuk gagal + pesan', () async {
      final s = await _siapkan(antrean: [_rec('u1', 'tiba', 'A')]);
      s.ds.kirim.add([
        HasilCheckinModel.fromJson({
          'noResi': 'A',
          'diabaikan': true,
          'pesan': 'Status tidak berubah',
        }),
      ]);

      await s.repo.sinkronkan();

      final gagal = s.queue.gagal(_nip).single;
      expect(gagal.diabaikan, isTrue);
      expect(gagal.pesanError, 'Status tidak berubah');
    });

    test('perubahan antrean diberitahukan', () async {
      final s = await _siapkan(antrean: [_rec('u1', 'tiba', 'A')]);
      s.ds.kirim.add(<HasilCheckinModel>[]);
      final perubahan = <RingkasanAntreanEntity>[];
      final sub = s.repo.perubahanAntrean.listen(perubahan.add);

      await s.repo.sinkronkan();
      await Future<void>.delayed(Duration.zero);

      expect(perubahan.last.menunggu, isEmpty);
      await sub.cancel();
    });

    test('hapus gagal', () async {
      final s = await _siapkan(antrean: [_rec('u1', 'tiba', 'A')]);
      s.ds.kirim.add(const ServerException(400, 'x'));
      await s.repo.sinkronkan();

      await s.repo.hapusGagal('u1');

      expect((await s.repo.bacaAntrean()).gagal, isEmpty);
    });
  });

  group('baca lain: master, detail, lacak', () {
    test('master dari server', () async {
      final s = await _siapkan();
      s.ds.master = MasterPengirimanModel.fromJson({
        'alasanGagal': [
          {'id': 1, 'nama': 'Rumah kosong'},
        ],
      });

      final r = await s.repo.getMaster();

      expect(
        r.getOrElse(() => throw 'gagal').alasanGagal.single.nama,
        'Rumah kosong',
      );
    });

    test('detail: online disimpan, offline dari cache + overlay', () async {
      final s = await _siapkan(antrean: [_rec('u1', 'tiba', 'A')]);
      s.ds.detail = BerkasDetailModel.fromJson({
        ...berkasJson(noResi: 'A', statusId: 4),
        'namaPenerima': null,
        'jejak': [
          {
            'statusId': 3,
            'status': 'Diambil',
            'tglCheckin': '2026-10-15T08:00:00',
          },
        ],
      });
      final online = (await s.repo.getDetail(
        'A',
      )).getOrElse(() => throw 'gagal');
      expect(online.dariCache, isFalse);
      // Overlay: tiba di antrean tampil di atas jejak server.
      expect(online.data.berkas.status, StatusBerkas.tiba);
      expect(online.data.jejak.first.belumTerkirim, isTrue);

      s.ds.detail = const NoInternetException();
      final offline = (await s.repo.getDetail(
        'A',
      )).getOrElse(() => throw 'gagal');
      expect(offline.dariCache, isTrue);
      expect(offline.data.berkas.noResi, 'A');
      expect(offline.data.jejak, hasLength(2));

      final tanpaCache = await s.repo.getDetail('B');
      expect(tanpaCache.isLeft(), isTrue);
    });

    test('lacak: diteruskan apa adanya, galat jadi Failure', () async {
      final s = await _siapkan();
      s.ds.lacak = LacakResultModel.fromJson({
        'noResi': 'A',
        'tugasSaya': true,
      });
      expect(
        (await s.repo.getLacak('A')).getOrElse(() => throw 'x').tugasSaya,
        isTrue,
      );

      s.ds.lacak = const ServerException(404, 'Berkas tidak ditemukan.');
      expect(
        (await s.repo.getLacak('X')).fold((f) => f.message, (_) => null),
        'Berkas tidak ditemukan.',
      );
    });
  });

  group('aksi: ambil online & simpan ke antrean', () {
    late Directory dir;
    late String foto;
    late PathProviderPlatform lama;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('repo_uji');
      foto = (File('${dir.path}/foto.jpg')..writeAsBytesSync([1, 2])).path;
      lama = PathProviderPlatform.instance;
      PathProviderPlatform.instance = FakePathProvider(dir.path);
    });

    tearDown(() {
      PathProviderPlatform.instance = lama;
      try {
        dir.deleteSync(recursive: true);
      } on FileSystemException catch (_) {}
    });

    CheckinPengirimanEntity checkin(String uuid) => CheckinPengirimanEntity(
      checkinUuid: uuid,
      tglCheckin: DateTime(2026, 10, 15, 9),
      latitude: -7.29,
      longitude: 112.75,
      isMockLocation: false,
      fotoLokasiPath: foto,
    );

    test('ambil: multipart dengan foto, hasil per berkas', () async {
      final s = await _siapkan();
      final r = await s.repo.postAmbil(
        AmbilPayloadEntity(
          noResiList: const ['A'],
          fotoAmbilPath: foto,
          checkin: checkin('u0'),
        ),
      );

      expect(r.getOrElse(() => throw 'x').single.status, StatusBerkas.diambil);
      expect(s.ds.formAmbil!.files.map((f) => f.key), [
        'fotoAmbil',
        'fotoLokasi',
      ]);
    });

    test(
      'tiba/serah/gagal/kembalikan: foto disalin ke folder antrean',
      () async {
        final s = await _siapkan();
        // Kirim otomatis setelah simpan ditahan (offline).
        s.ds.kirim.addAll(List.filled(4, const NoInternetException()));

        final hasil = [
          await s.repo.antreCheckin(
            CheckinPayloadEntity(
              jenis: JenisCheckin.tiba,
              noResi: 'A',
              checkin: checkin('u1'),
            ),
          ),
          await s.repo.antreSerah(
            SerahPayloadEntity(
              noResi: 'A',
              caraSerah: CaraSerah.ditempel,
              fotoTempelPath: foto,
              checkin: checkin('u2'),
            ),
          ),
          await s.repo.antreGagal(
            GagalPayloadEntity(
              noResi: 'B',
              idAlasan: 1,
              fotoGagalPath: foto,
              checkin: checkin('u3'),
            ),
          ),
          await s.repo.antreKembalikan(
            KembalikanPayloadEntity(
              noResiList: const ['B'],
              checkin: checkin('u4'),
            ),
          ),
        ];

        expect(hasil.every((h) => h.isRight()), isTrue);
        final antre = s.queue.menunggu(_nip);
        expect(antre.map((r) => r.jenis), [
          'tiba',
          'serah',
          'gagal',
          'kembalikan',
        ]);
        final salinan = antre.first.files['fotoLokasi']!;
        expect(salinan, isNot(foto));
        expect(salinan, contains('pengiriman_antrean'));
        expect(File(salinan).existsSync(), isTrue);
        expect((await s.repo.bacaAntrean()).menunggu, hasLength(4));
      },
    );

    test('foto hilang saat disimpan → CacheFailure', () async {
      final s = await _siapkan();
      final r = await s.repo.antreGagal(
        GagalPayloadEntity(
          noResi: 'A',
          idAlasan: 1,
          fotoGagalPath: '${dir.path}/tidak-ada.jpg',
          checkin: checkin('u9'),
        ),
      );

      expect(r.fold((f) => f, (_) => null), isA<CacheFailure>());
      expect(s.queue.menunggu(_nip), isEmpty);
    });

    test('kirim berjalan: panggilan kedua tidak menggandakan', () async {
      final s = await _siapkan(antrean: [_rec('u1', 'tiba', 'A')]);
      s.ds.kirim.add(<HasilCheckinModel>[]);

      await Future.wait([s.repo.sinkronkan(), s.repo.sinkronkan()]);

      expect(s.ds.terkirim, hasLength(1));
    });
  });

  group('rute peta (Routes API)', () {
    const titik = [TitikRute(-7.25, 112.73), TitikRute(-7.29, 112.75)];

    test('polyline jalan didekode jadi titik', () async {
      final s = await _siapkan();
      _rute.hasil = const RuteModel(encodedPolyline: '_p~iF~ps|U_ulLnnqC');

      final r = await s.repo.getRute(titik);

      expect(_rute.diminta, titik);
      expect(r.getOrElse(() => throw 'x'), const [
        TitikRute(38.5, -120.2),
        TitikRute(40.7, -120.95),
      ]);
    });

    test('Routes API menolak → Failure (peta cukup titik)', () async {
      final s = await _siapkan();
      _rute.hasil = const ServerException(403, 'API diblokir');

      final r = await s.repo.getRute(titik);

      expect(r.fold((f) => f.message, (_) => null), 'API diblokir');
    });
  });
}
