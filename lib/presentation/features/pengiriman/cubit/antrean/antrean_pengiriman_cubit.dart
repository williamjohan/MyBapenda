import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/network_cubit.dart';
import '../../../../../domain/usecases/pengiriman/pengiriman_usecase.dart';
import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import 'antrean_pengiriman_state.dart';

/// Antrean offline Pengiriman Surat (app-global, seperti NetworkCubit).
/// Mengirim ulang otomatis saat: HP kembali online, aplikasi dibuka lagi,
/// dan setelah login (lihat `main.dart`). Pemicu "setelah aksi disimpan"
/// ada di repository.
@lazySingleton
class AntreanPengirimanCubit extends Cubit<AntreanPengirimanState> {
  final PengirimanUseCase _useCase;
  final AuthCubit _auth;
  StreamSubscription<Object?>? _subAntrean;
  StreamSubscription<NetworkState>? _subJaringan;
  AppLifecycleListener? _lifecycle;

  AntreanPengirimanCubit(this._useCase, this._auth, NetworkCubit network)
    : super(const AntreanPengirimanState()) {
    _subAntrean = _useCase.perubahanAntrean.listen((r) {
      if (!isClosed) emit(state.copyWith(ringkasan: r));
    });
    _subJaringan = network.stream.listen((s) {
      if (s is NetworkConnected) kirim();
    });
    _lifecycle = AppLifecycleListener(onResume: kirim);
  }

  /// Baca antrean NIP login lalu coba kirim. Dipanggil saat app mulai dan
  /// tiap status login berubah.
  Future<void> muat() async {
    final r = await _useCase.bacaAntrean();
    if (isClosed) return;
    emit(state.copyWith(ringkasan: r));
    if (r.menunggu.isNotEmpty) await kirim();
  }

  Future<void> kirim() async {
    // Tanpa sesi login, request akan 401 (dan memicu logout paksa).
    if (state.sedangKirim || _auth.state is! AuthAuthenticated) return;
    emit(state.copyWith(sedangKirim: true));
    await _useCase.sinkronkan();
    final r = await _useCase.bacaAntrean();
    if (isClosed) return;
    emit(state.copyWith(ringkasan: r, sedangKirim: false));
  }

  Future<void> hapusGagal(String checkinUuid) =>
      _useCase.hapusGagal(checkinUuid);

  @override
  Future<void> close() {
    _subAntrean?.cancel();
    _subJaringan?.cancel();
    _lifecycle?.dispose();
    return super.close();
  }
}
