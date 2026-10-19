import 'package:bapendacore/domain/entities/cek_reklames/survey_permohonan_baru/detail_survey_entity.dart';
import 'package:bapendacore/domain/entities/cek_reklames/survey_permohonan_baru/survey_permohonan_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bapendacore/domain/usecases/survey_permohonan/survey_permohonan_usecase.dart';
import 'survey_list_state.dart';

class SurveyListCubit extends Cubit<SurveyListState> {
  final SurveyPermohonanUseCase _useCase;

  SurveyListCubit({required SurveyPermohonanUseCase useCase})
    : _useCase = useCase,
      super(const SurveyListState());

  Future<void> load() async {
    if (state.items.isEmpty) {
      emit(state.copyWith(status: SurveyListStatus.loading, clearError: true));
    }

    final result = await _useCase.getSurveyPermohonanHeader();
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SurveyListStatus.failure,
          error: failure.message,
        ),
      ),
      (items) => emit(
        state.copyWith(
          status: SurveyListStatus.success,
          items: items,
          clearError: true,
        ),
      ),
    );
  }

  Future<({List<Map<String, dynamic>>? sisi, String? error})> fetchSisi(
    SurveyPermohonanEntity e,
  ) async {
    if (state.isOpening) return (sisi: null, error: null);
    emit(state.copyWith(isOpening: true));

    try {
      final result = await _useCase.getSurveyDetail(key: e.key);
      if (isClosed) return (sisi: null, error: null);

      final header = _headerMap(e);

      return result.fold<({List<Map<String, dynamic>>? sisi, String? error})>(
        (failure) => (sisi: null, error: failure.message),
        (detail) {
          final prefill = _infoPrefill(detail);
          header['isDraft'] = detail.isDraft;
          return (
            sisi: detail.sisiList
                .map((s) => _sisiToMap(s, e, header, prefill))
                .toList(),
            error: null,
          );
        },
      );
    } catch (err, st) {
      debugPrint('fetchSisi error: $err\n$st');
      return (sisi: null, error: 'Gagal membaca data survey.');
    } finally {
      if (!isClosed) emit(state.copyWith(isOpening: false));
    }
  }

  /// Format masaTayang API: "08 Okt 2026 - 08 Okt 2027".
  Map<String, dynamic> _headerMap(SurveyPermohonanEntity e) {
    final p = e.masaTayang.split(RegExp(r'\s+-\s+'));
    return {
      'noPelayanan': e.noPelayanan,
      'npwpd': e.npwpd,
      'kategori': e.kategoriPenyelenggaraanNama,
      'statusPermohonan': e.statusPermohonan,
      'jenisReklameNama': e.jenisReklameNama,
      'lokPenyelenggaraan': e.lokPenyelenggaraan,
      'tglMulai': p.first.trim(),
      'tglSelesai': p.length > 1 ? p.last.trim() : '-',
      'dikembalikan': e.dikembalikanPenilaian,
      'ketPengembalian': e.ketPengembalian,
      'tglPengembalian': e.tglPengembalian,
    };
  }

  Map<String, dynamic> _sisiToMap(
    SisiListEntity s,
    SurveyPermohonanEntity e,
    Map<String, dynamic> header,
    Map<String, dynamic>? prefill,
  ) {
    final sv = s.survey;
    return {
      'header': header,
      if (prefill != null) 'infoPrefill': prefill,
      'seq': s.seq,
      'keySisi': s.keySisi,
      'imageUrl': s.imageUrl,
      'fotosWp': [
        if (s.imageUrl != null) {'url': s.imageUrl},
      ],
      'jenisReklameNama': s.jenisReklameNama ?? e.jenisReklameNama,
      'lokPenyelenggaraanPermohonan': s.lokPenyelenggaraanPermohonan,
      'materiReklamePermohonan': s.materiReklamePermohonan,
      'masaTayang': s.masaTayang ?? e.masaTayang,
      'nor': s.nor?.label,
      'survey': {
        if (sv != null) ...{
          'seq': sv.seq,
          'idNor': sv.idNor,
          'idPersil': sv.idPersil,
          'lokasiTertentuId': sv.lokasiTertentuId,
          'letakReklame': sv.letakReklame,
          'statusTanah': sv.statusTanah,
          'lokPenyelenggaraan': sv.lokPenyelenggaraan,
          'panjang': sv.panjang,
          'lebar': sv.lebar,
          'tinggi': sv.tinggi,
          'idJenisReklame': sv.idJenisReklame,
          'idJenisProduk': sv.idJenisProduk,
          'sudutPandang': sv.sudutPandang,
          'ketSisi': sv.ketSisi,
          'materiReklame': sv.materiReklame,
          'ketSurvey': sv.ketSurvey,
          // Titik reklame draft: jadi posisi awal pin di peta.
          'latitude': sv.latitude,
          'longitude': sv.longitude,
        },
        'fotos': const [],
      },
    };
  }

  Map<String, dynamic>? _infoPrefill(SurveyDetailEntity d) {
    final h = d.header;
    final c = d.checkin;
    final m = <String, dynamic>{
      if (h?.kecamatan != null) 'kecamatanId': h!.kecamatan,
      if (h?.kelurahan != null) 'kelurahanId': h!.kelurahan,
      if (h?.blok != null) 'blok': h!.blok,
      if (h?.rt != null) 'rt': h!.rt,
      if (h?.rw != null) 'rw': h!.rw,
      if (c != null && c.nipPembantu.isNotEmpty) 'nipPembantu': c.nipPembantu,
    };
    return m.isEmpty ? null : m;
  }

  void search(String q) => emit(state.copyWith(query: q));
}
