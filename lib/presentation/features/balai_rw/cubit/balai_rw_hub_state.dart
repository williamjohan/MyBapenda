// lib/presentation/features/balai_rw/cubit/balai_rw_hub_state.dart
import 'package:bapendacore/domain/entities/balai_rw/laporan_pegawai_entity.dart';
import 'package:bapendacore/domain/entities/balai_rw/roster_pegawai_entity.dart';
import 'package:bapendacore/presentation/shared/utils/date_util.dart';
import 'package:equatable/equatable.dart';

enum BalaiRwHubStatus { loading, ready, failure }

class BalaiRwHubState extends Equatable {
  final BalaiRwHubStatus status;
  final RosterPegawaiEntity? roster; // null = tidak ada penugasan hari ini
  final LaporanPegawaiEntity? laporan; // null = belum ada data hari ini
  final bool saving;
  final String? error;

  const BalaiRwHubState({
    this.status = BalaiRwHubStatus.loading,
    this.roster,
    this.laporan,
    this.saving = false,
    this.error,
  });

  static String? _norm(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    final t = DateUtil.parseJam(s);
    return t == null ? s : DateUtil.jamOf(t); 
  }

  String? get jamMasuk => _norm(laporan?.checkin?.jam);
  String? get jamPulang => _norm(laporan?.checkout?.jam);
  String? get fotoMasuk => laporan?.checkin?.fotoUrl;
  String? get fotoPulang => laporan?.checkout?.fotoUrl;
  List<JawabanEntity> get jawaban => laporan?.jawaban ?? const [];

  bool get laporanDone =>
      jawaban.any((j) => (j.jawaban ?? '').trim().isNotEmpty);

  BalaiRwHubState copyWith({
    BalaiRwHubStatus? status,
    bool? saving,
    String? error,
  }) => BalaiRwHubState(
    status: status ?? this.status,
    roster: roster,
    laporan: laporan,
    saving: saving ?? this.saving,
    error: error,
  );

  @override
  List<Object?> get props => [status, roster, laporan, saving, error];
}
