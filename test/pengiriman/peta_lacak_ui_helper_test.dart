import 'dart:ui';

import 'package:mybapenda/domain/entities/pengiriman/berkas_entity.dart';
import 'package:mybapenda/domain/entities/pengiriman/jejak_entity.dart';
import 'package:mybapenda/presentation/features/pengiriman/utils/peta_lacak_ui_helper.dart';
import 'package:flutter_test/flutter_test.dart';

JejakEntity _j(StatusBerkas s, {double? lat, double? lng}) =>
    JejakEntity(status: s, statusNama: s.label, latitude: lat, longitude: lng);

void main() {
  group('pin', () {
    test('kronologis, lewati tanpa koordinat, tujuan di depan', () {
      // Terbaru di atas.
      final pin = PetaLacakUiHelper.pin(
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
      expect(PetaLacakUiHelper.pin([_j(StatusBerkas.diambil)]), isEmpty);
    });

    test('jenis dari status', () {
      expect(PetaLacakUiHelper.jenisDari(StatusBerkas.diterima), JenisPin.tiba);
      expect(
        PetaLacakUiHelper.jenisDari(StatusBerkas.gagalAntar),
        JenisPin.gagal,
      );
      expect(
        PetaLacakUiHelper.jenisDari(StatusBerkas.dalamPerjalanan),
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
      final v = PetaLacakUiHelper.viewport([p], ukuran)!;
      expect(v.zoom, PetaLacakUiHelper.zoomTunggal);
      final o = v.posisi(p.lat, p.lng, ukuran);
      expect(o.dx, closeTo(180, 0.01));
      expect(o.dy, closeTo(90, 0.01));
    });

    test('semua titik masuk area dengan tepi', () {
      const pin = [
        PinPeta(lat: -7.25, lng: 112.73, jenis: JenisPin.transit, label: ''),
        PinPeta(lat: -7.30, lng: 112.78, jenis: JenisPin.tiba, label: ''),
      ];
      final v = PetaLacakUiHelper.viewport(pin, ukuran, tepi: 32)!;
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
      expect(PetaLacakUiHelper.viewport(const [], ukuran), isNull);
    });
  });

  group('URL Google Maps', () {
    PinPeta p(double lat, JenisPin j) =>
        PinPeta(lat: lat, lng: 112.7, jenis: j, label: '');

    test('banyak titik: arah dari check-in pertama, singgah, ke tujuan', () {
      final u = PetaLacakUiHelper.urlMaps([
        p(-7.30, JenisPin.tujuan),
        p(-7.25, JenisPin.transit),
        p(-7.27, JenisPin.transit),
        p(-7.29, JenisPin.tiba),
      ]);

      expect(u.path, '/maps/dir/');
      expect(u.queryParameters['origin'], '-7.25,112.7');
      expect(u.queryParameters['waypoints'], '-7.27,112.7|-7.29,112.7');
      expect(u.queryParameters['destination'], '-7.3,112.7');
      expect(u.queryParameters['travelmode'], 'two-wheeler');
    });

    test('titik singgah dibatasi, yang terbaru dipakai', () {
      final pin = [
        for (var i = 0; i < 12; i++) p(-7.0 - i / 100, JenisPin.transit),
      ];
      final singgah = PetaLacakUiHelper.urlMaps(
        pin,
      ).queryParameters['waypoints']!.split('|');

      expect(singgah, hasLength(PetaLacakUiHelper.maksSinggah));
      expect(singgah.last, '-7.1,112.7');
    });

    test('satu titik: cari lokasi', () {
      final u = PetaLacakUiHelper.urlMaps([p(-7.25, JenisPin.transit)]);
      expect(u.path, '/maps/search/');
      expect(u.queryParameters['query'], '-7.25,112.7');
    });
  });
}
