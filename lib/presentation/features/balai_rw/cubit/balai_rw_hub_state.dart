// lib/presentation/features/balai_rw/cubit/balai_rw_hub_state.dart
import 'package:bapendacore/domain/entities/balai_rw/laporan_pegawai_entity.dart';
import 'package:bapendacore/domain/entities/balai_rw/roster_pegawai_entity.dart';
import 'package:equatable/equatable.dart';

enum BalaiRwHubStatus { loading, ready, failure }

class BalaiRwHubState extends Equatable {
  final BalaiRwHubStatus status;
  final RosterPegawaiEntity? roster; // null = tidak ada penugasan hari ini
  final LaporanPegawaiEntity? laporan; // data terakhir dari server

  // ---- Draf (yang tampil di UI dan dikirim saat tombol Kirim ditekan)
  final String? jamMasuk; // "08.05"
  final String? jamPulang;
  final String? fotoMasuk; // path lokal atau URL server
  final String? fotoPulang;
  final List<JawabanEntity> jawaban;
  final String dihadiriOleh;
  final bool dirty; // ada perubahan yang belum dikirim

  final bool saving;
  final String? error;

  const BalaiRwHubState({
    this.status = BalaiRwHubStatus.loading,
    this.roster,
    this.laporan,
    this.jamMasuk,
    this.jamPulang,
    this.fotoMasuk,
    this.fotoPulang,
    this.jawaban = const [],
    this.dihadiriOleh = '',
    this.dirty = false,
    this.saving = false,
    this.error,
  });

  bool get laporanDone =>
      jawaban.any((j) => (j.jawaban ?? '').trim().isNotEmpty);

  bool get isComplete => jamMasuk != null && laporanDone && jamPulang != null;

  /// Catatan: field nullable tidak bisa di-null-kan lewat copyWith.
  BalaiRwHubState copyWith({
    BalaiRwHubStatus? status,
    RosterPegawaiEntity? roster,
    LaporanPegawaiEntity? laporan,
    String? jamMasuk,
    String? jamPulang,
    String? fotoMasuk,
    String? fotoPulang,
    List<JawabanEntity>? jawaban,
    String? dihadiriOleh,
    bool? dirty,
    bool? saving,
    String? error,
  }) => BalaiRwHubState(
    status: status ?? this.status,
    roster: roster ?? this.roster,
    laporan: laporan ?? this.laporan,
    jamMasuk: jamMasuk ?? this.jamMasuk,
    jamPulang: jamPulang ?? this.jamPulang,
    fotoMasuk: fotoMasuk ?? this.fotoMasuk,
    fotoPulang: fotoPulang ?? this.fotoPulang,
    jawaban: jawaban ?? this.jawaban,
    dihadiriOleh: dihadiriOleh ?? this.dihadiriOleh,
    dirty: dirty ?? this.dirty,
    saving: saving ?? this.saving,
    error: error,
  );

  @override
  List<Object?> get props => [
    status,
    roster,
    laporan,
    jamMasuk,
    jamPulang,
    fotoMasuk,
    fotoPulang,
    jawaban,
    dihadiriOleh,
    dirty,
    saving,
    error,
  ];
}
