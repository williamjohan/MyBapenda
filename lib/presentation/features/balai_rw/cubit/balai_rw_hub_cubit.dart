// lib/presentation/features/balai_rw/cubit/balai_rw_hub_cubit.dart
import 'dart:io';

import 'package:bapendacore/domain/entities/balai_rw/laporan_payload_entity.dart';
import 'package:bapendacore/domain/entities/balai_rw/laporan_pegawai_entity.dart';
import 'package:bapendacore/domain/entities/balai_rw/roster_pegawai_entity.dart';
import 'package:bapendacore/domain/usecases/balai_rw/balai_rw_usecase.dart';
import 'package:bapendacore/presentation/shared/utils/date_util.dart';
import 'package:bapendacore/presentation/shared/widgets/bt_image_compressor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'balai_rw_hub_state.dart';

@injectable
class BalaiRwHubCubit extends Cubit<BalaiRwHubState> {
  final BalaiRwUseCase _useCase;

  BalaiRwHubCubit(this._useCase) : super(const BalaiRwHubState());

  String get _today => DateUtil.iso(DateTime.now());

  /// "08:00:00" / "08:00" / "08.00" -> "08.00". Kosong -> null.
  static String? _normJam(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    final t = DateUtil.parseJam(s);
    return t == null ? s : DateUtil.jamOf(t);
  }

  String _apiJam(String jam) => jam.replaceAll('.', ':'); // 08.05 -> 08:05

  // ---------------------------------------------------------------- load

  Future<void> load() async {
    emit(state.copyWith(status: BalaiRwHubStatus.loading));

    final rosterRes = await _useCase.getRosterPegawai(
      tanggalAwal: _today,
      tanggalAkhir: _today,
    );
    if (isClosed) return;

    final rosters = rosterRes.fold<List<RosterPegawaiEntity>?>((f) {
      debugPrint('[BalaiRw] roster gagal: $f');
      return null;
    }, (r) => r);
    if (rosters == null) return _fail('Gagal memuat jadwal penugasan.');
    final roster = rosters.isEmpty ? null : rosters.first;

    LaporanPegawaiEntity? laporan;
    if (roster != null) {
      final lapRes = await _useCase.getLaporanAbsensi(
        tanggalAwal: _today,
        tanggalAkhir: _today,
      );
      if (isClosed) return;

      final list = lapRes.fold<List<LaporanPegawaiEntity>?>((f) {
        debugPrint('[BalaiRw] laporan gagal: $f');
        return null;
      }, (l) => l);
      if (list == null) return _fail('Gagal memuat laporan hari ini.');
      laporan = _pick(list, roster.idRoster);
    }

    // 3) draf awal = data server (kalau ada)
    final ci = laporan?.checkin;
    final co = laporan?.checkout;
    final ket = ci?.keterangan?.trim() ?? '';

    emit(
      BalaiRwHubState(
        status: BalaiRwHubStatus.ready,
        roster: roster,
        laporan: laporan,
        jamMasuk: _normJam(ci?.jam),
        jamPulang: _normJam(co?.jam),
        fotoMasuk: ci?.fotoUrl ?? state.fotoMasuk,
        fotoPulang: co?.fotoUrl ?? state.fotoPulang,
        jawaban: laporan?.jawaban ?? const [],
        dihadiriOleh: ket.isEmpty ? 'Staf Bapenda' : ket,
        dirty: false,
      ),
    );
  }

  void _fail(String msg) {
    // TODO: kalau Failure-mu punya pesan, pakai di sini.
    emit(state.copyWith(status: BalaiRwHubStatus.failure, error: msg));
  }

  static LaporanPegawaiEntity? _pick(
    List<LaporanPegawaiEntity> list,
    int idRoster,
  ) {
    for (final l in list) {
      if (l.idRoster == idRoster) return l;
    }
    return null;
  }

  // ------------------------------------------------- draf (tanpa POST)

  void setCheckin({required String jam, required String fotoPath}) =>
      emit(state.copyWith(jamMasuk: jam, fotoMasuk: fotoPath, dirty: true));

  void setCheckout({required String jam, required String fotoPath}) =>
      emit(state.copyWith(jamPulang: jam, fotoPulang: fotoPath, dirty: true));

  void setLaporan({
    required Map<String, String> jawaban, // idPertanyaan -> nilai
    required Map<String, String> pertanyaan, // idPertanyaan -> teks
    required String dihadiriOleh,
  }) {
    emit(
      state.copyWith(
        jawaban: [
          for (final e in jawaban.entries)
            JawabanEntity(
              idPertanyaan: int.parse(e.key),
              pertanyaan: pertanyaan[e.key] ?? '',
              jawaban: e.value,
            ),
        ],
        dihadiriOleh: dihadiriOleh,
        dirty: true,
      ),
    );
  }

  static const _serverDayOffset = 0;

  /// Tanggal diambil dari roster ("2026-10-07 00:00:00") -> "2026-10-07"
  String _tanggalKirim(RosterPegawaiEntity r) {
    final d = DateTime.parse(
      r.tanggal.split(' ').first,
    ).add(const Duration(days: _serverDayOffset));
    return DateUtil.iso(d);
  }

  // ---------------------------------------------------------- kirim

  Future<String?> submit() async {
    final roster = state.roster;
    if (roster == null) return 'Tidak ada penugasan hari ini.';
    if (roster.isLibur) return 'Hari ini libur, laporan tidak dapat dikirim.';
    if (state.jamMasuk == null) return 'Check-in belum diisi.';
    if (!state.laporanDone) return 'Laporan belum diisi.';
    if (state.jamPulang == null) return 'Check-out belum diisi.';

    final foto = state.fotoMasuk;
    final fotoLokal = (foto != null && !foto.startsWith('http')) ? foto : null;
    if (fotoLokal == null && state.laporan?.checkin?.fotoUrl == null) {
      return 'Foto check-in belum diambil.';
    }

    emit(state.copyWith(saving: true));

    String? fotoKirim;
    if (fotoLokal != null) {
      try {
        fotoKirim = await BtImageCompressor.toJpeg(fotoLokal);
        debugPrint(
          '[BalaiRw] foto ${await File(fotoLokal).length()} B '
          '-> ${await File(fotoKirim).length()} B',
        );
      } catch (e) {
        debugPrint('[BalaiRw] kompres gagal: $e');
        emit(state.copyWith(saving: false));
        return 'Gagal memproses foto. Coba ambil foto ulang.';
      }
    }

    final payload = LaporanPayloadEntity(
      tanggalLaporan: _tanggalKirim(roster),
      jawaban: [
        for (final j in state.jawaban)
          JawabanPayloadEntity(
            idPertanyaan: j.idPertanyaan,
            jawaban: j.jawaban ?? '',
          ),
      ],
      jamMasuk: _apiJam(state.jamMasuk!),
      jamPulang: _apiJam(state.jamPulang!),
      keterangan: state.dihadiriOleh,
      fotoPaths: [if (fotoKirim != null) fotoKirim],
    );

    debugPrint(
      '[BalaiRw] kirim tanggal=${payload.tanggalLaporan} '
      'foto=${payload.fotoPaths.length}',
    );

    final res = await _useCase.postLaporanPegawai(payload);
    if (isClosed) return null;

    final err = res.fold<String?>((f) {
      debugPrint('[BalaiRw] kirim gagal: $f');
      return 'Gagal mengirim laporan. Periksa koneksi lalu coba lagi.';
    }, (_) => null);
    if (err != null) {
      emit(state.copyWith(saving: false));
      return err;
    }

    // Ambil ulang dari server (jam, jawaban, dan foto yang tersimpan)
    await load();
    return null;
  }

  /// TODO: upload ke endpoint foto, kembalikan URL-nya.
  /// Path yang sudah berupa URL (foto dari server) dipakai apa adanya.
  Future<String?> _uploadFoto(String? path) async {
    if (path == null) return null;
    if (path.startsWith('http')) return path;
    return null;
  }
}
