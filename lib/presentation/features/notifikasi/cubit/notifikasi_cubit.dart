import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/entities/notifikasi/notifikasi_entity.dart';
import '../../../../domain/usecases/notifikasi/notifikasi_usecase.dart';
import 'notifikasi_state.dart';

/// Kotak masuk notifikasi petugas (terbaru dulu, per halaman).
@injectable
class NotifikasiCubit extends Cubit<NotifikasiState> {
  final NotifikasiUseCase _useCase;
  StreamSubscription<void>? _sub;

  static const _pageSize = 20;

  NotifikasiCubit(this._useCase) : super(const NotifikasiState()) {
    // Event baru / resume: muat ulang halaman pertama tanpa spinner.
    _sub = _useCase.perubahan.listen((_) => load(diam: true));
  }

  /// Urutan permintaan halaman pertama; jawaban basi diabaikan.
  int _urutan = 0;

  Future<void> load({bool diam = false}) async {
    final urutan = ++_urutan;
    if (!diam || state.items.isEmpty) {
      emit(state.copyWith(status: NotifikasiStatus.loading));
    }
    final result = await _useCase.getInbox(pageSize: _pageSize);
    if (isClosed || urutan != _urutan) return;
    result.fold(
      (f) => emit(
        state.copyWith(
          status: state.items.isEmpty
              ? NotifikasiStatus.failure
              : NotifikasiStatus.success,
          pesan: f.message,
        ),
      ),
      (h) {
        // Muat ulang diam saat sudah menggulir beberapa halaman: halaman
        // pertama diganti, sisanya dipertahankan supaya daftar tidak terpotong.
        if (diam && state.page > 1) {
          final baru = h.items.map((n) => n.id).toSet();
          emit(
            state.copyWith(
              status: NotifikasiStatus.success,
              items: [
                ...h.items,
                ...state.items.where((n) => !baru.contains(n.id)),
              ],
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            status: NotifikasiStatus.success,
            items: h.items,
            page: h.page,
            adaLagi: h.adaLagi,
            memuatLagi: false,
          ),
        );
      },
    );
  }

  Future<void> muatLagi() async {
    if (!state.adaLagi || state.memuatLagi) return;
    final urutan = _urutan;
    emit(state.copyWith(memuatLagi: true));
    final result = await _useCase.getInbox(
      page: state.page + 1,
      pageSize: _pageSize,
    );
    // Halaman pertama dimuat ulang di tengah jalan: hasil ini basi.
    if (isClosed || urutan != _urutan) return;
    result.fold(
      (f) => emit(state.copyWith(memuatLagi: false, pesan: f.message)),
      (h) {
        final ada = state.items.map((n) => n.id).toSet();
        emit(
          state.copyWith(
            items: [
              ...state.items,
              ...h.items.where((n) => !ada.contains(n.id)),
            ],
            page: h.page,
            adaLagi: h.adaLagi,
            memuatLagi: false,
          ),
        );
      },
    );
  }

  /// Tandai satu dibaca (optimistis; gagal = dikembalikan + pesan).
  Future<void> baca(NotifikasiEntity notif) async {
    if (notif.dibaca) return;
    final sebelum = state.items;
    emit(state.copyWith(items: _ganti(notif.tandaiDibaca(DateTime.now()))));
    final result = await _useCase.baca(notif.id);
    if (isClosed) return;
    result.fold(
      (f) => emit(state.copyWith(items: sebelum, pesan: f.message)),
      (_) {},
    );
  }

  Future<void> bacaSemua() async {
    if (!state.adaBelumDibaca) return;
    final sebelum = state.items;
    final now = DateTime.now();
    emit(state.copyWith(items: [for (final n in sebelum) n.tandaiDibaca(now)]));
    final result = await _useCase.bacaSemua();
    if (isClosed) return;
    result.fold(
      (f) => emit(state.copyWith(items: sebelum, pesan: f.message)),
      (_) {},
    );
  }

  List<NotifikasiEntity> _ganti(NotifikasiEntity baru) => [
    for (final n in state.items) n.id == baru.id ? baru : n,
  ];

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
