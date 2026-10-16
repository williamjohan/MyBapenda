import 'package:bapendacore/data/models/pengiriman/berkas_model.dart';
import 'package:bapendacore/domain/entities/pengiriman/berkas_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/pengiriman_fakes.dart';

/// `GET daftar` kini ikut berkas Diterima (hariDiterima default 30) dengan
/// field `tglSelesai`.
void main() {
  test('tglSelesai terbaca untuk berkas Diterima', () {
    final e = BerkasModel.fromJson({
      ...berkasJson(statusId: 6, aksi: []),
      'tglSelesai': '2026-10-15T14:30:00',
    }).toEntity();

    expect(e.status, StatusBerkas.diterima);
    expect(e.tglSelesai, DateTime(2026, 10, 15, 14, 30));
    expect(e.aksi, isEmpty);
    expect(BerkasModel.fromJson(berkasJson()).toEntity().tglSelesai, isNull);
  });

  test('Diterima walau terlambat tidak masuk Perlu Perhatian', () {
    expect(
      berkas(status: StatusBerkas.diterima, terlambat: true).perluPerhatian,
      isFalse,
    );
    expect(
      berkas(status: StatusBerkas.tiba, terlambat: true).perluPerhatian,
      isTrue,
    );
  });
}
