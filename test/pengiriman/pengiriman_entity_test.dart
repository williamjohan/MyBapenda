import 'package:bapendacore/domain/entities/pengiriman/antrean_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/berkas_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/jejak_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/lacak_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/master_pengiriman_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/pengiriman_payload_entity.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dua objek dengan isi sama harus setara (Equatable memakai semua field).
void _setara(Object Function() buat) {
  expect(buat(), buat());
  expect(buat().hashCode, buat().hashCode);
}

final _tgl = DateTime(2026, 10, 15, 9);

JejakEntity _jejak({double? lat, double? lng}) => JejakEntity(
  status: StatusBerkas.tiba,
  statusNama: 'Tiba di Tujuan',
  sumber: 'Petugas',
  nip: '1990',
  namaPetugas: 'Najib',
  tglCheckin: _tgl,
  latitude: lat,
  longitude: lng,
  akurasi: 8,
  jarakKeTujuan: 12,
  keterangan: 'Pagar',
  perluReview: true,
  jumlahFoto: 1,
  foto: const [FotoJejakEntity(key: 'k', jenisFoto: 'Lokasi')],
  flagAkurasi: true,
  flagWaktu: true,
  percobaanKe: 1,
);

BerkasEntity _berkas() => BerkasEntity(
  noResi: 'A',
  jenis: JenisSurat.skBongkar,
  jenisNama: 'SK Reklame Bongkar',
  noSurat: '973/1',
  tglSurat: _tgl,
  noReferensi: 'SKPD-1',
  npwpd: 'P1',
  namaWp: 'PT A',
  status: StatusBerkas.dalamPerjalanan,
  statusNama: 'Dalam Perjalanan',
  modeTempel: true,
  percobaanKe: 2,
  jumlahGagal: 1,
  jenisTujuan: 'Objek',
  alamatTujuan: 'Jl. A',
  latTujuan: -7.2,
  longTujuan: 112.7,
  penanggungJawab: true,
  tglDitugaskan: _tgl,
  tglBatasSla: _tgl,
  terlambat: true,
  wajibFotoObjek: true,
  aksi: const [AksiBerkas.tiba],
);

void main() {
  group('berkas', () {
    test('status dari id, status final, fallback', () {
      expect(StatusBerkas.fromId(6), StatusBerkas.diterima);
      expect(StatusBerkas.fromId(99), StatusBerkas.ditugaskan);
      expect(StatusBerkas.fromId(null), StatusBerkas.ditugaskan);
      expect(
        StatusBerkas.values.where((s) => s.isFinal),
        unorderedEquals([
          StatusBerkas.diterima,
          StatusBerkas.dikembalikan,
          StatusBerkas.dikirimViaPos,
          StatusBerkas.dibatalkan,
          StatusBerkas.tidakTerkirim,
        ]),
      );
    });

    test('jenis & aksi dari kode', () {
      expect(JenisSurat.fromKode(' skb '), JenisSurat.skBongkar);
      expect(JenisSurat.fromKode(null), JenisSurat.lainnya);
      expect(AksiBerkas.fromKode(' serah '), AksiBerkas.serah);
      expect(AksiBerkas.fromKode('X'), isNull);
    });

    test('kesetaraan, koordinat, tombol boleh', () {
      _setara(_berkas);
      final b = _berkas();
      expect(b.punyaKoordinat, isTrue);
      expect(b.boleh(AksiBerkas.tiba), isTrue);
      expect(b.boleh(AksiBerkas.serah), isFalse);
    });

    test('copyWith hanya mengganti field yang diisi', () {
      final b = _berkas();
      final c = b.copyWith(
        status: StatusBerkas.tiba,
        statusNama: 'Tiba',
        perluDikembalikan: true,
        aksi: const [AksiBerkas.serah],
        antreanTertunda: 2,
      );
      expect(c.status, StatusBerkas.tiba);
      expect(c.antreanTertunda, 2);
      expect(c.perluDikembalikan, isTrue);
      expect(c.noResi, b.noResi);
      expect(c.latTujuan, b.latTujuan);
      expect(b.copyWith(), b);
    });

    test('detail berkas: setara & copyWith', () {
      BerkasDetailEntity d() => BerkasDetailEntity(
        berkas: _berkas(),
        alamatWp: 'Jl. WP',
        caraSerah: 'Langsung',
        tglTerima: _tgl,
        namaPenerima: 'Budi',
        jejak: [_jejak()],
      );
      _setara(d);
      final c = d().copyWith(jejak: const []);
      expect(c.jejak, isEmpty);
      expect(c.namaPenerima, 'Budi');
      expect(d().copyWith(), d());
    });
  });

  group('jejak & lacak', () {
    test('jejak: setara, koordinat', () {
      _setara(() => _jejak(lat: 1, lng: 2));
      expect(_jejak(lat: 1, lng: 2).punyaKoordinat, isTrue);
      expect(_jejak(lat: 1).punyaKoordinat, isFalse);
      _setara(() => const FotoJejakEntity(key: 'k'));
    });

    test('monitoring & hasil lacak: setara', () {
      MonitoringBerkasEntity m() => MonitoringBerkasEntity(
        noResi: 'A',
        jenis: JenisSurat.teguran,
        jenisNama: 'Teguran',
        noSurat: '1',
        tglSurat: _tgl,
        noReferensi: 'S',
        npwpd: 'P',
        namaWp: 'WP',
        alamatWp: 'Jl',
        uptb: 'UPTB 1',
        status: StatusBerkas.dikirimViaPos,
        statusNama: 'Via Pos',
        nipPetugas: '1',
        namaPetugas: 'N',
        jumlahGagal: 2,
        maksPercobaan: 3,
        modeTempel: true,
        tglDitugaskan: _tgl,
        tglBatasSla: _tgl,
        tglJatuhTempo: _tgl,
        tglTerima: _tgl,
        caraSerah: 'Pos',
        terlambat: true,
        perluReview: true,
        fisikBelumKembali: true,
        tindakan: 'Cek',
        noResiPos: 'POS1',
        tglKirimPos: _tgl,
        tglUpdate: _tgl,
        jejak: [_jejak()],
      );
      _setara(m);
      _setara(
        () => LacakResultEntity(
          noResi: 'A',
          aksesMonitoring: true,
          tugasSaya: true,
          monitoring: m(),
          tugas: BerkasDetailEntity(berkas: _berkas()),
        ),
      );
    });
  });

  group('master, payload, antrean', () {
    test('master & cara serah', () {
      _setara(
        () => const MasterPengirimanEntity(
          hubunganPenerima: [OpsiMasterEntity(id: 1, nama: 'Pemilik')],
          alasanGagal: [
            OpsiMasterEntity(id: 2, nama: 'Lain', wajibKeterangan: true),
          ],
          caraSerah: [OpsiMasterEntity(id: 1, nama: 'Langsung')],
        ),
      );
      expect(CaraSerah.fromId(3), CaraSerah.ditempel);
      expect(CaraSerah.fromId(9), isNull);
      expect(CaraSerah.ditempel.butuhPenerima, isFalse);
      expect(CaraSerah.dititipkan.butuhPenerima, isTrue);
    });

    test('check-in & hasil check-in: setara', () {
      _setara(
        () => CheckinPengirimanEntity(
          checkinUuid: 'u',
          tglCheckin: _tgl,
          latitude: 1,
          longitude: 2,
          akurasi: 3,
          isMockLocation: false,
          keterangan: 'k',
          fotoLokasiPath: '/f',
        ),
      );
      _setara(
        () => const HasilCheckinEntity(
          noResi: 'A',
          status: StatusBerkas.tiba,
          statusNama: 'Tiba',
          diabaikan: true,
          duplikat: true,
          pesan: 'p',
        ),
      );
    });

    test('antrean: kode aksi, ringkasan, hasil baca', () {
      expect(JenisAksiAntrean.fromKode('serah'), JenisAksiAntrean.serah);
      expect(JenisAksiAntrean.fromKode('?'), JenisAksiAntrean.perjalanan);
      expect(JenisAksiAntrean.serah.statusSetelah, StatusBerkas.diterima);

      AntreanPengirimanEntity a() => AntreanPengirimanEntity(
        checkinUuid: 'u',
        jenis: JenisAksiAntrean.gagal,
        noResi: const ['A'],
        tglDibuat: _tgl,
        jmlCoba: 1,
        pesan: 'p',
        diabaikan: true,
      );
      _setara(a);
      final r = RingkasanAntreanEntity(menunggu: [a()], gagal: [a(), a()]);
      expect(r.jumlah, 3);
      _setara(() => RingkasanAntreanEntity(menunggu: [a()]));

      expect(HasilBacaEntity(1, tglCache: _tgl).dariCache, isTrue);
      expect(const HasilBacaEntity(1).dariCache, isFalse);
      _setara(() => HasilBacaEntity('x', tglCache: _tgl));
    });
  });
}
