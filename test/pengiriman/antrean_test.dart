import 'package:mybapenda/core/errors/exception.dart';
import 'package:mybapenda/core/storage/pengiriman_queue_storage.dart';
import 'package:mybapenda/data/models/pengiriman/pengiriman_payload_model.dart';
import 'package:mybapenda/data/repositories/pengiriman/pengiriman_antrean_overlay.dart';
import 'package:mybapenda/data/repositories/pengiriman/pengiriman_repository_impl.dart';
import 'package:mybapenda/domain/entities/pengiriman/antrean_entity.dart';
import 'package:mybapenda/domain/entities/pengiriman/berkas_entity.dart';
import 'package:mybapenda/domain/entities/pengiriman/master_pengiriman_entity.dart';
import 'package:mybapenda/domain/entities/pengiriman/pengiriman_payload_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

const _berkas = BerkasEntity(
  noResi: 'HMB1',
  jenis: JenisSurat.himbauan,
  jenisNama: 'Himbauan',
  namaWp: 'PT A',
  alamatTujuan: '-',
  status: StatusBerkas.diambil,
  statusNama: 'Diambil',
  aksi: [AksiBerkas.perjalanan, AksiBerkas.tiba, AksiBerkas.gagal],
);

AntreanPengirimanEntity _antre(JenisAksiAntrean j, {String resi = 'HMB1'}) =>
    AntreanPengirimanEntity(
      checkinUuid: '${j.kode}-$resi',
      jenis: j,
      noResi: [resi],
      tglDibuat: DateTime(2026, 10, 14, 9),
    );

void main() {
  test('tombol aksi per status (cermin aturan server)', () {
    List<AksiBerkas> aksi(StatusBerkas s, {bool kembali = false}) =>
        PengirimanAntreanOverlay.aksiUntuk(s, kembali);

    expect(aksi(StatusBerkas.ditugaskan), [AksiBerkas.ambil]);
    expect(aksi(StatusBerkas.diambil), [
      AksiBerkas.perjalanan,
      AksiBerkas.tiba,
      AksiBerkas.gagal,
    ]);
    expect(aksi(StatusBerkas.dalamPerjalanan), aksi(StatusBerkas.diambil));
    expect(aksi(StatusBerkas.tiba), [AksiBerkas.serah, AksiBerkas.gagal]);
    expect(aksi(StatusBerkas.gagalAntar), [AksiBerkas.kembalikan]);
    expect(aksi(StatusBerkas.dibatalkan, kembali: true), [
      AksiBerkas.kembalikan,
    ]);
    // Setelah serah terima / dikembalikan: tombol bawah hilang.
    for (final s in [
      StatusBerkas.diterima,
      StatusBerkas.dikembalikan,
      StatusBerkas.dibatalkan,
      StatusBerkas.dikirimViaPos,
    ]) {
      expect(aksi(s), isEmpty, reason: s.name);
    }
  });

  group('overlay antrean', () {
    test('tiba tertunda: status Tiba, tombol Serah/Gagal, ditandai', () {
      final b = PengirimanAntreanOverlay.berkas(_berkas, [
        _antre(JenisAksiAntrean.tiba),
      ]);
      expect(b.status, StatusBerkas.tiba);
      expect(b.aksi, [AksiBerkas.serah, AksiBerkas.gagal]);
      expect(b.antreanTertunda, 1);
    });

    test('berurutan: gagal lalu kembalikan → Dikembalikan tanpa aksi', () {
      final b = PengirimanAntreanOverlay.berkas(_berkas, [
        _antre(JenisAksiAntrean.gagal),
        _antre(JenisAksiAntrean.kembalikan),
      ]);
      expect(b.status, StatusBerkas.dikembalikan);
      expect(b.perluDikembalikan, isFalse);
      expect(b.aksi, isEmpty);
    });

    test('antrean berkas lain tidak berpengaruh', () {
      final b = PengirimanAntreanOverlay.berkas(_berkas, [
        _antre(JenisAksiAntrean.tiba, resi: 'HMB2'),
      ]);
      expect(identical(b, _berkas), isTrue);
    });

    test('detail: jejak belum terkirim di paling atas', () {
      final d = PengirimanAntreanOverlay.detail(
        const BerkasDetailEntity(berkas: _berkas),
        [_antre(JenisAksiAntrean.perjalanan), _antre(JenisAksiAntrean.tiba)],
      );
      expect(d.jejak.first.status, StatusBerkas.tiba);
      expect(d.jejak.every((j) => j.belumTerkirim), isTrue);
    });
  });

  group('klasifikasi galat kirim', () {
    DioException http(int code) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: code,
        data: {
          'isSuccess': false,
          'errors': ['Ditolak'],
        },
      ),
    );

    test('ditolak bisnis & 4xx → permanen', () {
      expect(
        klasifikasiGagalKirim(const ServerException(200, 'x')).permanen,
        isTrue,
      );
      expect(klasifikasiGagalKirim(http(400)).permanen, isTrue);
    });

    test('5xx, 401, timeout → dicoba lagi', () {
      expect(klasifikasiGagalKirim(http(500)).permanen, isFalse);
      expect(klasifikasiGagalKirim(http(401)).permanen, isFalse);
      expect(
        klasifikasiGagalKirim(
          DioException(
            requestOptions: RequestOptions(path: '/x'),
            type: DioExceptionType.connectionTimeout,
          ),
        ).permanen,
        isFalse,
      );
    });
  });

  test('rekaman antrean: field & file sesuai kontrak, JSON bolak-balik', () {
    final rec = SerahPayloadEntity(
      noResi: 'HMB1',
      caraSerah: CaraSerah.langsung,
      namaPenerima: 'Budi',
      idHubungan: 2,
      fotoSerahPath: '/tmp/serah.jpg',
      fotoTtdPath: '/tmp/ttd.png',
      checkin: CheckinPengirimanEntity(
        checkinUuid: 'u-1',
        tglCheckin: DateTime(2026, 10, 14, 9, 5),
        latitude: -7.2,
        longitude: 112.7,
        isMockLocation: false,
      ),
    ).toRecord();

    final balik = AntreanRecord.fromJson(rec.toJson());
    expect(balik.endpoint, '/api/pengiriman/serah');
    expect(balik.checkinUuid, 'u-1');
    expect(balik.files.keys, ['fotoSerah', 'fotoTtd']);
    expect(balik.fields.any((f) => f[0] == 'caraSerah' && f[1] == '1'), isTrue);
    expect(balik.toEntity().jenis, JenisAksiAntrean.serah);
  });
}
