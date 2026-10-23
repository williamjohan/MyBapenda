import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

// Import Core
import '../../../../core/errors/failure.dart';

// Import Entities
import '../../entities/cek_reklames/survey_permohonan_baru/cari_nor_entity.dart';
import '../../entities/cek_reklames/survey_permohonan_baru/detail_survey_entity.dart';
import '../../entities/cek_reklames/survey_permohonan_baru/simpan_survey_hasil_entity.dart';
import '../../entities/cek_reklames/survey_permohonan_baru/simpan_survey_request_entity.dart';
import '../../entities/cek_reklames/survey_permohonan_baru/survey_permohonan_entity.dart';

// Import Repository
import '../../repositories/survey_permohonan/i_survey_permohonan_repository.dart';

@lazySingleton
class SurveyPermohonanUseCase {
  final ISurveyPermohonanRepository _repository;

  SurveyPermohonanUseCase(this._repository);

  // 1. GET LIST HEADER SURVEY
  Future<Either<Failure, List<SurveyPermohonanEntity>>>
  getSurveyPermohonanHeader() {
    return _repository.getSurveyPermohonanHeader();
  }

  // 2. GET DETAIL SURVEY
  /// Mengambil rincian detail dari satu tugas survey berdasarkan [key]
  Future<Either<Failure, SurveyDetailEntity>> getSurveyDetail({
    required String key,
  }) {
    return _repository.getSurveyDetail(key: key);
  }

  // 3. POST SIMPAN SURVEY: draft, lalu langsung submit bila isian lengkap
  Future<Either<Failure, SimpanSurveyHasilEntity>> submitSurvey(
    SimpanSurveyRequestEntity payload,
  ) {
    return _repository.submitSurvey(payload);
  }

  // 4. CARI NOR (Nomor Objek Reklame)
  Future<Either<Failure, List<CariNorEntity>>> cariNor({required String nor}) {
    return _repository.cariNor(nor: nor);
  }

  // 5. GET SUMMARY
  Future<Either<Failure, SurveySummaryEntity>> getSurveySummary() {
    return _repository.getSurveySummary();
  }

  // 6. RADIUS MAKSIMAL PIN REKLAME
  /// Dipakai bila server belum punya setting dan belum pernah ada cache
  /// (keputusan user 2026-10-17, diperketat dari 50 m).
  static const radiusBawaanMeter = 20;

  Future<Either<Failure, int>> getRadiusSurvey({bool forceRefresh = false}) {
    return _repository.getRadiusSurvey(forceRefresh: forceRefresh);
  }

  /// Radius baru dari push SignalR (`PENGATURAN_SURVEY`).
  Future<void> perbaruiRadius(int meter) => _repository.perbaruiRadius(meter);

  /// Radius berubah selama app berjalan; halaman Lokasi yang terbuka ikut
  /// memakai nilai baru.
  Stream<int> get radiusBerubah => _repository.radiusBerubah;

  /// Radius maksimal pin reklame dari posisi petugas (meter). Urutan:
  /// [dariForm] (`survey-form`), lalu `pengaturan-radius-survey` (cache
  /// memori/disk), lalu [radiusBawaanMeter]. Tidak pernah gagal.
  Future<int> radiusSurvey({int? dariForm}) async {
    if (dariForm != null && dariForm > 0) return dariForm;
    final result = await _repository.getRadiusSurvey();
    return result.fold((_) => radiusBawaanMeter, (meter) => meter);
  }
}
