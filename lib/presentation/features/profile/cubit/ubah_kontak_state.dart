// lib/presentation/features/profile/cubit/ubah_kontak_state.dart
import 'package:equatable/equatable.dart';

import '../../../../domain/entities/profile/jenis_kontak.dart';
import '../../../../domain/entities/profile/kontak_profil_entity.dart';

/// input = isi email / no WA; otp = masukkan kode; selesai = terverifikasi.
enum UbahKontakStep { input, otp, selesai }

class UbahKontakState extends Equatable {
  final JenisKontak kontak;
  final String nilaiSekarang;
  final UbahKontakStep step;

  /// Tujuan yang dikirim saat kirim OTP (kosong = kontak sekarang).
  final String tujuan;

  /// Tujuan yang tampil ke pengguna (kontak sekarang bila `tujuan` kosong).
  final String tujuanTampil;
  final bool mengirim;
  final bool memverifikasi;

  /// Detik tersisa sebelum boleh kirim ulang OTP.
  final int sisaJedaDetik;
  final KontakProfilEntity? hasil;
  final String? error;
  final String? info;

  const UbahKontakState({
    this.kontak = JenisKontak.email,
    this.nilaiSekarang = '',
    this.step = UbahKontakStep.input,
    this.tujuan = '',
    this.tujuanTampil = '',
    this.mengirim = false,
    this.memverifikasi = false,
    this.sisaJedaDetik = 0,
    this.hasil,
    this.error,
    this.info,
  });

  bool get bolehKirimUlang => !mengirim && sisaJedaDetik <= 0;

  UbahKontakState copyWith({
    JenisKontak? kontak,
    String? nilaiSekarang,
    UbahKontakStep? step,
    String? tujuan,
    String? tujuanTampil,
    bool? mengirim,
    bool? memverifikasi,
    int? sisaJedaDetik,
    KontakProfilEntity? hasil,
    String? error,
    String? info,
  }) => UbahKontakState(
    kontak: kontak ?? this.kontak,
    nilaiSekarang: nilaiSekarang ?? this.nilaiSekarang,
    step: step ?? this.step,
    tujuan: tujuan ?? this.tujuan,
    tujuanTampil: tujuanTampil ?? this.tujuanTampil,
    mengirim: mengirim ?? this.mengirim,
    memverifikasi: memverifikasi ?? this.memverifikasi,
    sisaJedaDetik: sisaJedaDetik ?? this.sisaJedaDetik,
    hasil: hasil ?? this.hasil,
    error: error,
    info: info,
  );

  @override
  List<Object?> get props => [
    kontak,
    nilaiSekarang,
    step,
    tujuan,
    tujuanTampil,
    mengirim,
    memverifikasi,
    sisaJedaDetik,
    hasil,
    error,
    info,
  ];
}
