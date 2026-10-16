// lib/presentation/features/profile/cubit/ubah_kontak_cubit.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/entities/profile/jenis_kontak.dart';
import '../../../../domain/usecases/profile/profile_usecase.dart';
import 'ubah_kontak_state.dart';

/// Ubah / verifikasi email atau no WA: kirim OTP -> verifikasi OTP.
@injectable
class UbahKontakCubit extends Cubit<UbahKontakState> {
  final ProfileUseCase _useCase;
  Timer? _timer;

  UbahKontakCubit(this._useCase) : super(const UbahKontakState());

  void mulai({required JenisKontak kontak, required String nilaiSekarang}) =>
      emit(UbahKontakState(kontak: kontak, nilaiSekarang: nilaiSekarang));

  /// Langkah 1: kirim OTP ke `input` (sama dengan kontak sekarang = verifikasi).
  Future<void> kirimOtp(String input) async {
    if (state.mengirim) return;
    final nilai = input.trim();
    if (nilai.isEmpty) {
      emit(state.copyWith(error: '${state.kontak.label} wajib diisi.'));
      return;
    }
    final salah = _useCase.validasiTujuan(state.kontak, nilai);
    if (salah != null) {
      emit(state.copyWith(error: salah));
      return;
    }

    await _kirim(
      tujuan: _useCase.tujuanKirim(input: nilai, sekarang: state.nilaiSekarang),
      tujuanTampil: nilai,
    );
  }

  Future<void> kirimUlang() async {
    if (!state.bolehKirimUlang) return;
    await _kirim(tujuan: state.tujuan, tujuanTampil: state.tujuanTampil);
  }

  Future<void> _kirim({
    required String tujuan,
    required String tujuanTampil,
  }) async {
    emit(state.copyWith(mengirim: true));

    final result = await _useCase.kirimOtpKontak(
      kontak: state.kontak,
      tujuan: tujuan,
    );
    if (isClosed) return;

    result.fold(
      (failure) =>
          emit(state.copyWith(mengirim: false, error: failure.message)),
      (otp) {
        emit(
          state.copyWith(
            step: UbahKontakStep.otp,
            tujuan: tujuan,
            tujuanTampil: tujuanTampil,
            mengirim: false,
            sisaJedaDetik: otp.sisaJedaKirimDetik,
            info: 'Kode OTP telah dikirim ke $tujuanTampil',
          ),
        );
        _mulaiHitungMundur();
      },
    );
  }

  /// Langkah 2: verifikasi kode OTP 6 digit.
  Future<void> verifikasi(String kode) async {
    if (state.memverifikasi) return;
    final salah = _useCase.validasiKode(kode);
    if (salah != null) {
      emit(state.copyWith(error: salah));
      return;
    }

    emit(state.copyWith(memverifikasi: true));

    final result = await _useCase.verifikasiOtpKontak(
      kontak: state.kontak,
      tujuan: state.tujuan,
      kode: kode,
    );
    if (isClosed) return;

    result.fold(
      (failure) =>
          emit(state.copyWith(memverifikasi: false, error: failure.message)),
      (kontak) {
        _timer?.cancel();
        emit(
          state.copyWith(
            step: UbahKontakStep.selesai,
            memverifikasi: false,
            hasil: kontak,
          ),
        );
      },
    );
  }

  /// Kembali ke langkah input untuk mengganti tujuan.
  void ubahTujuan() {
    _timer?.cancel();
    emit(state.copyWith(step: UbahKontakStep.input, sisaJedaDetik: 0));
  }

  void _mulaiHitungMundur() {
    _timer?.cancel();
    if (state.sisaJedaDetik <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (isClosed) return t.cancel();
      final sisa = state.sisaJedaDetik - 1;
      emit(state.copyWith(sisaJedaDetik: sisa < 0 ? 0 : sisa));
      if (sisa <= 0) t.cancel();
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
