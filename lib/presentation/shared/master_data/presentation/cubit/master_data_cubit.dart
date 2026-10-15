import 'package:bapendacore/presentation/shared/master_data/domain/entities/master_option_type.dart';
import 'package:bapendacore/presentation/shared/master_data/domain/usecases/master_data_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'master_data_state.dart';

@lazySingleton
class MasterDataCubit extends Cubit<MasterDataState> {
  final MasterDataUseCase _useCase;

  MasterDataCubit(this._useCase) : super(const MasterDataState());

  /// Panggil saat option dibutuhkan (mis. dropdown dibuka).
  /// Kalau sudah pernah dimuat, tidak fetch lagi kecuali [force].
  Future<void> loadOption(MasterOptionType type, {bool force = false}) async {
    if (state.loading.contains(type)) return;
    if (!force && state.options.containsKey(type)) return;

    emit(
      state.copyWith(
        loading: {...state.loading, type},
        failed: {...state.failed}..remove(type),
      ),
    );

    final result = await _useCase.getOptions(type, forceRefresh: force);
    if (isClosed) return;

    result.fold(
      (failure) {
        debugPrint('Master ${type.label} gagal dimuat: $failure');
        final hasData = state.options.containsKey(type);
        emit(
          state.copyWith(
            loading: {...state.loading}..remove(type),
            // Kalau refresh gagal tapi data lama ada, jangan tandai error.
            failed: hasData ? null : {...state.failed, type},
          ),
        );
      },
      (items) => emit(
        state.copyWith(
          options: {...state.options, type: items},
          loading: {...state.loading}..remove(type),
          failed: {...state.failed}..remove(type),
        ),
      ),
    );
  }

  /// Opsional: muat beberapa option sekaligus (mis. saat buka form).
  Future<void> loadOptions(Iterable<MasterOptionType> types) =>
      Future.wait(types.map(loadOption));

  Future<void> loadKelurahan(String kecamatanId, {bool force = false}) async {
    if (!force && state.kelurahan.containsKey(kecamatanId)) return;

    emit(
      state.copyWith(
        kelurahanLoadingFor: () => kecamatanId,
        kelurahanErrorFor: () => null,
      ),
    );

    final result = await _useCase.getKelurahan(
      kecamatanId,
      forceRefresh: force,
    );
    if (isClosed) return;

    final stillCurrent = state.kelurahanLoadingFor == kecamatanId;

    result.fold(
      (failure) {
        debugPrint('Kelurahan ($kecamatanId) gagal dimuat: $failure');
        if (!stillCurrent) return;
        emit(
          state.copyWith(
            kelurahanLoadingFor: () => null,
            kelurahanErrorFor: () => kecamatanId,
          ),
        );
      },
      (items) => emit(
        state.copyWith(
          kelurahan: {...state.kelurahan, kecamatanId: items},
          kelurahanLoadingFor: stillCurrent ? () => null : null,
          kelurahanErrorFor: stillCurrent ? () => null : null,
        ),
      ),
    );
  }
}
