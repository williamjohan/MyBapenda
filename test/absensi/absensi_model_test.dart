import 'package:bapendacore/data/models/absensi/absen_model.dart';
import 'package:bapendacore/data/models/absensi/riwayat_absensi_model.dart';
import 'package:bapendacore/data/models/absensi/ringkasan_absensi_model.dart';
import 'package:bapendacore/domain/entities/absensi/absen_entity.dart';
import 'package:bapendacore/domain/entities/absensi/riwayat_absensi_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RingkasanAbsensiModel', () {
    test('memakai masuk/pulang dari API apa adanya (pulang boleh null)', () {
      final entity = RingkasanAbsensiModel.fromJson({
        'nip': '3506192511010005',
        'nama': 'MOCHAMMAD MIFTACHUN NAJIB',
        'tanggal': '2026-10-02',
        'masuk': '2026-10-02T06:10:22',
        'pulang': null,
        'jamMasukJadwal': '07:30',
        'jamPulangJadwal': '16:30',
        'menitTelat': 0,
        'menitPsw': 0,
        'keterangan': 'H',
      }).toEntity();

      expect(entity.masuk, DateTime(2026, 10, 2, 6, 10, 22));
      expect(entity.pulang, isNull);
      expect(entity.isTelat, isFalse);
    });

    test('waktu WIB tanpa offset tidak digeser zona waktu', () {
      final entity = RingkasanAbsensiModel.fromJson({
        'tanggal': '2026-10-02',
        'masuk': '2026-10-02T07:33:01',
      }).toEntity();

      expect(entity.masuk!.hour, 7);
      expect(entity.masuk!.isUtc, isFalse);
      expect(entity.menitTelat, 0);
    });
  });

  group('RiwayatAbsensiPageModel', () {
    Map<String, dynamic> page(int p) => {
      'page': p,
      'pageSize': 20,
      'total': 134,
      'items': [
        {
          'tglPresensi': '2026-10-02T07:33:01',
          'jenisDevice': 1,
          'namaDevice': 'Ponsel 24069PC21G',
          'sumber': 'ONLINE',
          'isValid': true,
          'keterangan': null,
          'namaLokasi': 'Kantor Bapenda Jimerto',
        },
        {
          'tglPresensi': '2026-10-01T16:40:00',
          'jenisDevice': 2,
          'sumber': 'SYNC',
          'isValid': false,
        },
      ],
    };

    test('memetakan item & sumber', () {
      final result = RiwayatAbsensiPageModel.fromJson(page(1)).toEntity();

      expect(result.items, hasLength(2));
      expect(result.items.first.sumber, SumberAbsensi.online);
      expect(result.items.last.sumber, SumberAbsensi.sync);
      expect(result.items.last.isValid, isFalse);
    });

    test('hasMore berdasarkan page * pageSize < total', () {
      expect(
        RiwayatAbsensiPageModel.fromJson(page(1)).toEntity().hasMore,
        isTrue,
      );
      expect(
        RiwayatAbsensiPageModel.fromJson(page(7)).toEntity().hasMore,
        isFalse,
      );
    });
  });

  test('AbsenResultModel memetakan jenis & ringkasan', () {
    final entity = AbsenResultModel.fromJson({
      'tglPresensi': '2026-10-02T07:42:41',
      'jenis': 'MASUK',
      'namaLokasi': 'Kantor Bapenda Jimerto',
      'jarakMeter': 24.3,
      'menitTelat': 12,
      'menitPsw': 0,
      'ringkasan': {
        'nip': '1',
        'nama': 'A',
        'tanggal': '2026-10-02',
        'masuk': '2026-10-02T07:42:41',
        'menitTelat': 12,
        'menitPsw': 0,
      },
    }).toEntity(message: 'Absen masuk tercatat');

    expect(entity.jenis, JenisAbsen.masuk);
    expect(entity.menitTelat, 12);
    expect(entity.ringkasan.masuk, DateTime(2026, 10, 2, 7, 42, 41));
    expect(entity.message, 'Absen masuk tercatat');
  });
}
