import 'dart:ui';

import 'package:bapendacore/domain/entities/pengiriman/berkas_entity.dart';
import 'package:bapendacore/domain/entities/pengiriman/jejak_entity.dart';
import 'package:bapendacore/presentation/features/pengiriman/logic/peta_lacak_logic.dart';
import 'package:flutter_test/flutter_test.dart';

JejakEntity _j(StatusBerkas s, {double? lat, double? lng}) =>
    JejakEntity(status: s, statusNama: s.label, latitude: lat, longitude: lng);

void main() {
  group('pin', () {
    test('kronologis, lewati tanpa koordinat, tujuan di depan', () {
      // Terbaru di atas.
      final pin = PetaLacakLogic.pin(
        [
          _j(StatusBerkas.tiba, lat: -7.30, lng: 112.78),
          _j(StatusBerkas.dalamPerjalanan),
          _j(StatusBerkas.dalamPerjalanan, lat: -7.28, lng: 112.75),
          _j(StatusBerkas.diambil, lat: -7.25, lng: 112.73),
        ],
        latTujuan: -7.301,
        longTujuan: 112.781,
      );

      expect(pin.map((p) => p.jenis), [
        JenisPin.tujuan,
        JenisPin.transit,
        JenisPin.transit,
        JenisPin.tiba,
      ]);
      expect(pin.first.terbaru, isFalse);
      expect(pin.last.terbaru, isTrue);
      expect(pin.where((p) => p.terbaru), hasLength(1));
    });

    test('tanpa koordinat tujuan & jejak → kosong', () {
      expect(PetaLacakLogic.pin([_j(StatusBerkas.diambil)]), isEmpty);
    });

    test('jenis dari status', () {
      expect(PetaLacakLogic.jenisDari(StatusBerkas.diterima), JenisPin.tiba);
      expect(PetaLacakLogic.jenisDari(StatusBerkas.gagalAntar), JenisPin.gagal);
      expect(
        PetaLacakLogic.jenisDari(StatusBerkas.dalamPerjalanan),
        JenisPin.transit,
      );
    });
  });

  group('viewport', () {
    const ukuran = Size(360, 180);

    test('satu titik → zoom tunggal, titik di tengah', () {
      const p = PinPeta(
        lat: -7.3,
        lng: 112.7,
        jenis: JenisPin.transit,
        label: '',
      );
      final v = PetaLacakLogic.viewport([p], ukuran)!;
      expect(v.zoom, PetaLacakLogic.zoomTunggal);
      final o = v.posisi(p.lat, p.lng, ukuran);
      expect(o.dx, closeTo(180, 0.01));
      expect(o.dy, closeTo(90, 0.01));
    });

    test('semua titik masuk area dengan tepi', () {
      const pin = [
        PinPeta(lat: -7.25, lng: 112.73, jenis: JenisPin.transit, label: ''),
        PinPeta(lat: -7.30, lng: 112.78, jenis: JenisPin.tiba, label: ''),
      ];
      final v = PetaLacakLogic.viewport(pin, ukuran, tepi: 32)!;
      for (final p in pin) {
        final o = v.posisi(p.lat, p.lng, ukuran);
        expect(o.dx, inInclusiveRange(32, 328));
        expect(o.dy, inInclusiveRange(32, 148));
      }
      // Zoom satu tingkat lebih besar sudah tidak muat.
      final besar = ViewportPeta(lat: v.lat, lng: v.lng, zoom: v.zoom + 1);
      final keluar = pin.any((p) {
        final o = besar.posisi(p.lat, p.lng, ukuran);
        return o.dy < 32 || o.dy > 148 || o.dx < 32 || o.dx > 328;
      });
      expect(keluar, isTrue);
    });

    test('kosong → null', () {
      expect(PetaLacakLogic.viewport(const [], ukuran), isNull);
    });
  });
}
