import 'dart:io';
import 'package:bapendacore/domain/entities/cek_reklames/survey_permohonan_baru/simpan_survey_hasil_entity.dart';
import 'package:bapendacore/domain/entities/cek_reklames/survey_permohonan_baru/simpan_survey_request_entity.dart';
import 'package:bapendacore/presentation/shared/widgets/bt_image_compressor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bapendacore/domain/usecases/survey_permohonan/survey_permohonan_usecase.dart';
import '../../screens/survey_foto_page.dart'; // SurveyResult

/// state = true saat sedang mengirim.
class SurveySubmitCubit extends Cubit<bool> {
  final SurveyPermohonanUseCase _useCase;

  SurveySubmitCubit({required SurveyPermohonanUseCase useCase})
    : _useCase = useCase,
      super(false);

  // File hasil kompres yang dibuat saat submit. Dihapus setelah selesai.
  final List<String> _temps = [];

  /// Kirim ke `simpan-survey`. Hanya sisi yang ada di [results] yang
  /// dikirim, jadi dipakai juga untuk Simpan Draft (sisi lain tetap memakai
  /// draft tersimpan di server). Server menyimpan draft lalu langsung
  /// submit ke penilaian bila semua isian lengkap: lihat
  /// [SimpanSurveyHasilEntity.terkirim].
  Future<({SimpanSurveyHasilEntity? hasil, String? error})> submit({
    required Map<String, dynamic> info,
    required List<Map<String, dynamic>> sisiList,
    required Map<int, SurveyResult> results,
  }) async {
    if (state) return (hasil: null, error: null);
    emit(true);
    try {
      final request = await _build(info, sisiList, results); // <-- await
      final result = await _useCase.submitSurvey(request);
      return result.fold<({SimpanSurveyHasilEntity? hasil, String? error})>(
        (failure) => (hasil: null, error: failure.message),
        (hasil) => (hasil: hasil, error: null),
      );
    } on StateError catch (e) {
      return (hasil: null, error: e.message);
    } catch (e, st) {
      debugPrint('submit survey error: $e\n$st');
      return (hasil: null, error: 'Gagal menyiapkan data survey.');
    } finally {
      _cleanTemps();
      if (!isClosed) emit(false);
    }
  }

  // ---- Helper ----

  Future<File> _compress(String path) async {
    try {
      final out = await BtImageCompressor.toJpeg(path);
      _temps.add(out);
      return File(out);
    } catch (e) {
      debugPrint('compress error: $e');
      throw StateError('Gagal memperkecil ukuran foto. Coba ambil ulang foto.');
    }
  }

  void _cleanTemps() {
    for (final p in _temps) {
      try {
        File(p).deleteSync();
      } catch (_) {}
    }
    _temps.clear();
  }

  String _req(Map<String, dynamic> m, String k) {
    final v = m[k];
    if (v == null || '$v'.trim().isEmpty) {
      throw StateError('Data "$k" belum terisi');
    }
    return '$v'.trim();
  }

  int _reqInt(Map<String, dynamic> m, String k) {
    final v = m[k];
    if (v is int) return v;
    final p = int.tryParse('$v');
    if (p == null) throw StateError('Data "$k" belum terisi');
    return p;
  }

  double _reqNum(Map<String, dynamic> m, String k) {
    final v = m[k];
    final n = v is num ? v.toDouble() : double.tryParse('$v');
    if (n == null) throw StateError('Data "$k" belum terisi');
    return n;
  }

  int? _optInt(Map<String, dynamic> m, String k) {
    final v = m[k];
    return v is int ? v : int.tryParse('${v ?? ''}');
  }

  /// Ukuran <= 0 = belum diisi.
  double? _optUkuran(Map<String, dynamic> m, String k) {
    final v = m[k];
    final n = v is num ? v.toDouble() : double.tryParse('${v ?? ''}');
    return n != null && n > 0 ? n : null;
  }

  bool _norBaruLengkap(Map nb) =>
      nb['persilId'] != null &&
      nb['jenisBangunanId'] != null &&
      nb['namaJalanId'] != null &&
      '${nb['noAlamat'] ?? ''}'.trim().isNotEmpty;

  /// "-" (hasil autofill yang tidak ketemu) dikirim sebagai kosong.
  String _clean(dynamic v) {
    final s = '${v ?? ''}'.trim();
    return s == '-' ? '' : s;
  }

  String _fmt(DateTime d) {
    String p(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${p(d.month)}-${p(d.day)}'
        'T${p(d.hour)}:${p(d.minute)}:${p(d.second)}';
  }

  // ---- Mapping Map UI -> Entity ----

  Future<SimpanSurveyRequestEntity> _build(
    Map<String, dynamic> info,
    List<Map<String, dynamic>> sisiList,
    Map<int, SurveyResult> results,
  ) async {
    final lat = _reqNum(info, 'latitude').toStringAsFixed(6);
    final lng = _reqNum(info, 'longitude').toStringAsFixed(6);
    final tgl = DateTime.tryParse('${info['tanggalSurvey']}') ?? DateTime.now();

    // PERBAIKAN: Baca sebagai List<String>, bukan String?
    // Pastikan key-nya sama persis dengan yang dikirim dari _payload di SurveyInfoPage
    final pembantuList =
        (info['nipPembantu'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];

    final sisi = <SisiRequestEntity>[];
    for (final s in sisiList) {
      final r = results[s['seq']];
      if (r != null) sisi.add(await _sisi(r, s));
    }
    if (sisi.isEmpty) throw StateError('Belum ada sisi yang disurvey');

    final selfie = await _compress(_req(info, 'selfiePath'));

    return SimpanSurveyRequestEntity(
      key: _req(info, 'key'),
      tglSurvey: _fmt(tgl),
      kecamatan: _req(info, 'kecamatanId'),
      kelurahan: _req(info, 'kelurahanId'),
      lokBlok: _clean(info['blok']),
      lokRt: _clean(info['rt']),
      lokRw: _clean(info['rw']),
      sisiList: sisi,
      checkin: CheckinRequestEntity(
        fileDataFormFile: selfie,
        latitude: lat,
        longitude: lng,
        alamat: '${info['alamat'] ?? '-'}',
        // PERBAIKAN: Langsung masukkan list yang sudah diekstrak
        nipPembantu: pembantuList,
      ),
    );
  }

  Future<SisiRequestEntity> _sisi(
    SurveyResult r,
    Map<String, dynamic> sisi,
  ) async {
    final d = r.data;
    final nb = d['norBaru'];
    final survey = sisi['survey'];

    final persilBaru = nb is Map ? nb['persilId'] as String? : null;
    final persilLama = survey is Map ? survey['idPersil']?.toString() : null;
    final idNorLama = survey is Map ? survey['idNor']?.toString() : null;

    final seq = _reqInt(d, 'seq');
    // Titik reklame = pin di peta (wajib per sisi), bukan lokasi petugas.
    final lokasi = r.lokasi;
    if (lokasi == null) {
      throw StateError('Titik reklame sisi $seq belum dipilih di peta');
    }

    // Foto dari server (URL) tidak bisa di-upload sebagai File.
    final path = r.foto.path;
    final File? fotoFile = path.startsWith('http')
        ? null
        : await _compress(path); // <-- await

    return SisiRequestEntity(
      seq: seq,
      latitude: lokasi.lat.toStringAsFixed(7),
      longitude: lokasi.lng.toStringAsFixed(7),
      idNor: d['idNor']?.toString() ?? idNorLama,
      idPersil: persilBaru ?? persilLama,
      // Isian boleh kosong (draft); kelengkapan dicek server (kurangLengkap).
      lokasiTertentuId: _optInt(d, 'lokasiTertentuId'),
      letakReklame: _optInt(d, 'letakReklame'),
      statusTanah: _optInt(d, 'statusTanah'),
      // Kontrak: id master lokasi penyelenggaraan (teks), bukan namanya.
      lokPenyelenggaraan: d['lokasiPenyelenggaraanId']?.toString() ?? '',
      panjang: _optUkuran(d, 'panjang'),
      lebar: _optUkuran(d, 'lebar'),
      tinggi: _optUkuran(d, 'tinggi'),
      idJenisReklame: _optInt(d, 'idJenisReklame'),
      idJenisProduk: _optInt(d, 'idJenisProduk'),
      sudutPandang: _optInt(d, 'sudutPandang'),
      ketSisi: d['ketSisi'] as String? ?? '',
      materiReklame: d['materiReklame'] as String? ?? '',
      ketSurvey: d['ketSurvey'] as String? ?? '',
      // NOR baru dikirim hanya bila lengkap (dipakai server saat submit);
      // draft cukup menyimpan persilnya lewat idPersil.
      norBaru: nb is Map && _norBaruLengkap(nb)
          ? NorBaruRequestEntity(
              idPersil: persilBaru,
              jenisBangunanId: nb['jenisBangunanId'] as int?,
              jalanId: nb['namaJalanId'] as int?,
              noAlamat: nb['noAlamat'] as String? ?? '',
            )
          : null,
      fotos: [
        if (fotoFile != null)
          FotoRequestEntity(file: fotoFile, keterangan: r.foto.keterangan),
      ],
    );
  }
}
