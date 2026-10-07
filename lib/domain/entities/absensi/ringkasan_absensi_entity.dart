import 'package:equatable/equatable.dart';

/// Ringkasan kehadiran satu hari.
///
/// [masuk] / [pulang] dihitung server memakai window jadwal di LibKantor,
/// BUKAN scan pertama/terakhir. Jangan hitung ulang di mobile.
class RingkasanAbsensiEntity extends Equatable {
  final String nip;
  final String nama;
  final DateTime tanggal;
  final DateTime? masuk;
  final DateTime? pulang;

  /// Format "HH:mm", null jika hari tanpa jadwal.
  final String? jamMasukJadwal;
  final String? jamPulangJadwal;

  final int menitTelat;

  /// Pulang sebelum waktu (menit).
  final int menitPsw;

  /// `H` hadir, `M` mangkir, `*` tanpa jadwal, `R` libur, kode izin lain,
  /// null = hari ini belum ada scan.
  final String? keterangan;

  const RingkasanAbsensiEntity({
    required this.nip,
    required this.nama,
    required this.tanggal,
    this.masuk,
    this.pulang,
    this.jamMasukJadwal,
    this.jamPulangJadwal,
    this.menitTelat = 0,
    this.menitPsw = 0,
    this.keterangan,
  });

  bool get isTelat => menitTelat > 0;
  bool get isPulangCepat => menitPsw > 0;

  @override
  List<Object?> get props => [
    nip,
    nama,
    tanggal,
    masuk,
    pulang,
    jamMasukJadwal,
    jamPulangJadwal,
    menitTelat,
    menitPsw,
    keterangan,
  ];
}
