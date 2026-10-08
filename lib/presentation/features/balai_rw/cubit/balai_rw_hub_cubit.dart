// lib/presentation/features/balai_rw/cubit/balai_rw_hub_cubit.dart
import 'dart:io';

import 'package:bapendacore/core/errors/failure.dart';
import 'package:bapendacore/domain/entities/balai_rw/laporan_payload_entity.dart';
import 'package:bapendacore/domain/entities/balai_rw/laporan_pegawai_entity.dart';
import 'package:bapendacore/domain/entities/balai_rw/roster_pegawai_entity.dart';
import 'package:bapendacore/domain/usecases/balai_rw/balai_rw_usecase.dart';
import 'package:bapendacore/presentation/shared/utils/date_util.dart';
import 'package:bapendacore/presentation/shared/widgets/bt_image_compressor.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'balai_rw_hub_state.dart';

@injectable
class BalaiRwHubCubit extends Cubit<BalaiRwHubState> {
  final BalaiRwUseCase _useCase;

  BalaiRwHubCubit(this._useCase) : super(const BalaiRwHubState());

  String get _today => DateUtil.iso(DateTime.now());

  /// TODO: sementara 0. Kalau server memang menggeser tanggal (+1 hari),
  /// isi -1 di sini sebagai penambal, hapus kalau backend sudah benar.
  static const _serverDayOffset = 0;

  String _tanggalKirim(RosterPegawaiEntity r) {
    final d = DateTime.parse(
      r.tanggal.split(' ').first,
    ).add(const Duration(days: _serverDayOffset));
    return DateUtil.iso(d);
  }

  /// 08.05 -> 08:05:00
  String _apiJamDetik(String jam) => '${jam.replaceAll('.', ':')}:00';

  // ---------------------------------------------------------------- load

  /// [silent] true = tanpa spinner layar penuh (dipakai setelah POST).
  Future<void> load({bool silent = false}) async {
    if (!silent) emit(state.copyWith(status: BalaiRwHubStatus.loading));

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

    emit(
      BalaiRwHubState(
        status: BalaiRwHubStatus.ready,
        roster: roster,
        laporan: laporan,
      ),
    );
  }

  void _fail(String msg) {
    // TODO: kalau Failure-mu punya pesan, pakai di sini.
    emit(
      state.copyWith(
        status: BalaiRwHubStatus.failure,
        saving: false,
        error: msg,
      ),
    );
  }

  /// Kalau ada beberapa laporan di hari yang sama, ambil idLaporan terbesar.
  static LaporanPegawaiEntity? _pick(
    List<LaporanPegawaiEntity> list,
    int idRoster,
  ) {
    LaporanPegawaiEntity? best;
    LaporanPegawaiEntity? any;
    for (final l in list) {
      if (any == null || l.idLaporan > any.idLaporan) any = l;
      if (l.idRoster != idRoster) continue;
      if (best == null || l.idLaporan > best.idLaporan) best = l;
    }
    return best ?? any;
  }
  // ------------------------------------------------------ kirim (3 POST)
  // Semua mengembalikan pesan error (null = sukses).

  Future<String?> submitCheckin({
    required String jam, // "08.05"
    required String fotoPath,
    double? lat,
    double? lng,
  }) {
    return _post('check-in', () async {
      final foto = await _prepFoto(fotoPath);
      return _useCase.postCheckin(
        CheckinPayloadEntity(
          tanggalLaporan: _tanggalKirim(state.roster!),
          waktuCheckIn: _apiJamDetik(jam),
          fotoPath: foto,
          latitude: lat,
          longitude: lng,
        ),
      );
    });
  }

  Future<String?> submitLaporan({
    required Map<String, String> jawaban, // idPertanyaan -> nilai
  }) {
    if (state.jamMasuk == null) {
      return Future.value('Selesaikan check-in dulu.');
    }
    return _post('laporan', () {
      return _useCase.postLaporanPegawai(
        LaporanPayloadEntity(
          tanggalLaporan: _tanggalKirim(state.roster!),
          jawaban: [
            for (final e in jawaban.entries)
              JawabanPayloadEntity(
                idPertanyaan: int.parse(e.key),
                jawaban: e.value,
              ),
          ],
        ),
      );
    });
  }

  Future<String?> submitCheckout({
    required String fotoPath,
    required double lat,
    required double lng,
  }) {
    if (!state.laporanDone) return Future.value('Isi laporan dulu.');
    return _post('check-out', () async {
      final foto = await _prepFoto(fotoPath);
      return _useCase.postCheckout(
        CheckoutPayloadEntity(
          tanggalLaporan: _tanggalKirim(state.roster!),
          fotoPath: foto,
          latitude: lat,
          longitude: lng,
        ),
      );
    });
  }

  // ------------------------------------------------------------- helpers

  Future<String?> _post(
    String nama,
    Future<Either<Failure, bool>> Function() call,
  ) async {
    final r = state.roster;
    if (r == null) return 'Tidak ada penugasan hari ini.';
    if (r.isLibur) return 'Hari ini libur.';

    emit(state.copyWith(saving: true));
    try {
      final res = await call();
      if (isClosed) return null;

      final failed = res.fold<bool>((f) {
        debugPrint('[BalaiRw] $nama gagal: $f');
        return true;
      }, (_) => false);
      if (failed) {
        emit(state.copyWith(saving: false));
        return 'Gagal mengirim $nama. Periksa koneksi lalu coba lagi.';
      }
    } catch (e) {
      debugPrint('[BalaiRw] $nama error: $e');
      if (!isClosed) emit(state.copyWith(saving: false));
      return 'Gagal memproses $nama. Coba ambil foto ulang.';
    }

    await load(silent: true); // ambil ulang dari server
    return null;
  }

  /// Kompres ke JPEG supaya tidak kena 413.
  Future<String> _prepFoto(String path) async {
    final out = await BtImageCompressor.toJpeg(path);
    debugPrint(
      '[BalaiRw] foto ${await File(path).length() ~/ 1024} KB '
      '-> ${await File(out).length() ~/ 1024} KB',
    );
    return out;
  }
}
