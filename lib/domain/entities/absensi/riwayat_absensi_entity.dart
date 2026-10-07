import 'package:equatable/equatable.dart';

enum SumberAbsensi {
  /// Absen dari aplikasi HP.
  online,

  /// Sinkron dari mesin fingerprint.
  sync,

  /// Diinput manual oleh admin.
  manual;

  static SumberAbsensi fromCode(String? code) {
    switch (code?.toUpperCase()) {
      case 'SYNC':
        return SumberAbsensi.sync;
      case 'MANUAL':
        return SumberAbsensi.manual;
      default:
        return SumberAbsensi.online;
    }
  }
}

class RiwayatAbsensiEntity extends Equatable {
  final DateTime tglPresensi;

  /// 1 = HP, 2 = mesin finger.
  final int jenisDevice;
  final String? namaDevice;
  final SumberAbsensi sumber;

  /// false = ditolak (fake GPS / dibatalkan), tetap ditampilkan tapi redup.
  final bool isValid;
  final String? keterangan;
  final String? namaLokasi;

  const RiwayatAbsensiEntity({
    required this.tglPresensi,
    required this.jenisDevice,
    this.namaDevice,
    required this.sumber,
    required this.isValid,
    this.keterangan,
    this.namaLokasi,
  });

  @override
  List<Object?> get props => [
    tglPresensi,
    jenisDevice,
    namaDevice,
    sumber,
    isValid,
    keterangan,
    namaLokasi,
  ];
}

class RiwayatAbsensiPageResult {
  final List<RiwayatAbsensiEntity> items;
  final int page;
  final int pageSize;
  final int total;

  const RiwayatAbsensiPageResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  bool get hasMore => page * pageSize < total;
}
