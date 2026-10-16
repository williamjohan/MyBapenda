import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../domain/usecases/notifikasi/notifikasi_usecase.dart';

/// Jumlah notifikasi belum dibaca untuk lonceng di Home. Kontrak: TIDAK
/// polling REST; nilai = `jumlahBelumDibaca` dari event hub terakhir
/// (snapshot dikirim server saat connect & setelah status baca berubah).
@injectable
class NotifikasiBadgeCubit extends Cubit<int> {
  StreamSubscription<int>? _sub;

  NotifikasiBadgeCubit(NotifikasiUseCase useCase)
    : super(useCase.jumlahTerakhir ?? 0) {
    _sub = useCase.jumlahBelumDibaca.listen((n) {
      if (!isClosed) emit(n);
    });
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
