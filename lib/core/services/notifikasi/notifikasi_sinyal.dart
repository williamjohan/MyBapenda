import 'dart:async';

import 'package:injectable/injectable.dart';

/// Kabar dari hub (lewat foreground service) di isolate utama. Kontrak: app
/// TIDAK polling; badge = `jumlahBelumDibaca` dari event `NOTIF` terakhir.
@lazySingleton
class NotifikasiSinyal {
  final _event = StreamController<void>.broadcast();
  final _jumlah = StreamController<int>.broadcast();

  int? _jumlahTerakhir;

  /// Event `NOTIF` datang (baru atau snapshot): kotak masuk yang terbuka
  /// memuat ulang halaman 1.
  Stream<void> get event => _event.stream;

  /// Nilai badge setiap ada event.
  Stream<int> get jumlahBelumDibaca => _jumlah.stream;

  /// Nilai badge terakhir; null = belum ada event sejak app dibuka.
  int? get jumlahTerakhir => _jumlahTerakhir;

  void terima({required int jumlahBelumDibaca}) {
    _jumlahTerakhir = jumlahBelumDibaca;
    _jumlah.add(jumlahBelumDibaca);
    _event.add(null);
  }
}
